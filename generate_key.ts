import { Lucid } from "https://deno.land/x/lucid@0.10.10/mod.ts";

const seedPhrase = "heart outdoor element clinic mushroom clap undo author clip upper silk combine trade illegal ship shoe woman witness green ketchup blame choice spice promote";

// Generate private key from seed phrase
const privateKey = await Lucid.fromSeed(seedPhrase);
console.log("Private Key:", privateKey);

// Save to file
await Deno.writeTextFile("./signature/owner.seed", privateKey);
console.log("Saved private key to ./signature/owner.seed"); 