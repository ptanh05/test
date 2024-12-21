use cardano/assets.{PolicyId, AssetName}
use cardano/transaction.{Transaction, InlineDatum, OutputReference, Output, NoDatum }
use aiken/crypto.{ VerificationKeyHash,}
use cardano/address.{Address, VerificationKey}
use aiken/interval
use aiken/builtin
use aiken/collection/list
//Asset about ADA, NFT
pub type Asset{
    policy_id: PolicyId,//id nft
    token_name: AssetName,// name nft
    amt: Int, //ADA or lovelace
}
//status transaction
pub type InheritanceStatus{
    Unlocked 
    Locked
    Claimed
    Refunded
}
//data in a transaction of owner and beneficiary
pub type Datum{
    owner: VerificationKeyHash,
    beneficiary: VerificationKeyHash,
    lock_until: Int,//time lock
    status: InheritanceStatus,
    message: ByteArray,
    nft: Asset,
    locked_ada: Int,
    plc: PolicyId,
}
pub type Action{
    //owner lock assets
    Lock
    //owner want to refund
    Refund
    //beneficiary claim assets when end lock_until
    Claim
}
pub fn value_sent_to_address(vkey: VerificationKeyHash, tx: Transaction) -> Int {
  tx.outputs
    |> list.filter(fn(output) {
         when output.address.payment_credential is {
           VerificationKey(pkh) -> pkh == vkey
           _ -> False
         }
       })
    |> list.map(fn(output) { assets.lovelace_of(output.value) })
    |> list.foldl(0, fn(a, b) { a + b })
}

validator dedicate{
    spend(datum_opt: Option<Datum>, redeemer: Action, own_ref: OutputReference, tx: Transaction)-> Bool{
        expect Some(datum) = datum_opt
        when redeemer is{
            Lock -> {
                and {
                    list.has(tx.extra_signatories, datum.owner), // owner sign
                    datum.status == Unlocked,
                    datum.nft.policy_id == datum.plc,
                    when list.head(tx.outputs) is {
                        Some(output)->
                        when output.datum is {
                            InlineDatum(d) -> {
                            let expected_datum = Datum { 
                                owner: datum.owner,
                                beneficiary: datum.beneficiary,
                                lock_until: datum.lock_until,
                                status: Locked,
                                message: datum.message,
                                nft: datum.nft,
                                locked_ada: datum.locked_ada,
                                plc: datum.plc,
                            }
                           builtin.equals_data(d,expected_datum)
                            }
                            _-> False

                        }
                            None -> False
                        }
                        }
                    }
                
    
            Refund -> {
                and{
                list.has(tx.extra_signatories, datum.owner),
                datum.status == Locked,
                interval.is_entirely_before(tx.validity_range, datum.lock_until),
                datum.nft.policy_id == datum.plc,
                value_sent_to_address(datum.owner, tx) >= datum.locked_ada,
              }
            }
            Claim -> {
                and {
                    list.has(tx.extra_signatories, datum.beneficiary),
                    datum.status == Locked,
                    interval.is_entirely_after(tx.validity_range, datum.lock_until),
                    datum.nft.policy_id ==datum.plc,
                    value_sent_to_address(datum.beneficiary, tx) >= datum.locked_ada,
                }
            }
        }
    }
}
