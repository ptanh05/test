import { Lucid } from "https://deno.land/x/lucid@0.10.11/mod.ts";
import { Blockfrost } from "https://deno.land/x/lucid@0.10.11/mod.ts";

const lucid = await Lucid.new(
    new Blockfrost(
        "https://cardano-preview.blockfrost.io/api/v0",
        "previewP0pgwulal3HfojJLi0T5p1bhPkFjWuvi"
    ),
    "Preview"
);

lucid.selectWalletFromSeed(await Deno.readTextFile("./owner.seed"));

const tx = await lucid.newTx()
    .payToAddress("addr_test1qp32dhvj6nmhn8qjce8vsv3s0x70rrth7udxy32a7lm5yl7vchlp2ahqwyyfpv4l7fszccrngx2vcmmu5x3d3t3cy2uqpd7ewx",
        { lovelace: 1_000_000n }).complete();

const signedTx = await tx.sign().complete();
const txHash = await signedTx.submit();
console.log("txHash: ",txHash);
// deno run --allow-net --allow-read --allow-env test.ts


  
