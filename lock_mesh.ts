import { MeshVestingContract } from "@meshsdk/contract";
import {BrowserWallet,
    IFetcher,
    IWallet,
    LanguageVersion,
    MeshTxBuilder,
    MeshWallet,
    serializePlutusScript,
    UTxO, } from "@meshsdk/core";

const blockchainProvider = new BlockfrostProvider('previewP0pgwulal3HfojJLi0T5p1bhPkFjWuvi');

const meshTxBuilder = new MeshTxBuilder({
  fetcher: blockchainProvider,
  submitter: blockchainProvider,
});
//xay dung mesh
const contract = new MeshVestingContract({
  mesh: meshTxBuilder,
  fetcher: blockchainProvider,
  wallet: wallet,
  networkId: 0,
});
const assets: Asset[] = [
    {
      unit: "lovelace",
      quantity: '5000000',
    },
  ];
  
  const lockUntilTimeStamp = new Date();
  lockUntilTimeStamp.setMinutes(lockUntilTimeStamp.getMinutes() + 1);
  
  const beneficiary = 'addr_test1qp32dhvj6nmhn8qjce8vsv3s0x70rrth7udxy32a7lm5yl7vchlp2ahqwyyfpv4l7fszccrngx2vcmmu5x3d3t3cy2uqpd7ewx';
  const tx = await contract.depositFund(
    assets,
    lockUntilTimeStamp.getTime(),
    beneficiary,
  );
  const signedTx = await wallet.signTx(tx);
  const txHash = await wallet.submitTx(signedTx);