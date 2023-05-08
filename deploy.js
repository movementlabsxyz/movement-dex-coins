const aptos = require("aptos");
const fs = require("fs");
const HexString = aptos.HexString;
const shellJs = require("shelljs");
const NODE_URL = "https://submove.bbd.sh/v1";

// Call the `start` function when the script is executed
start();

async function start() {

  const PK = ""
  const PK_BYTES = new HexString(PK).toUint8Array()

  const client = new aptos.AptosClient(NODE_URL);
  // Create a new account
  const account = new aptos.AptosAccount(PK_BYTES);

  // Compile the contract
  shellJs.exec("aptos move compile --save-metadata");
  // Load the contract
  const packageMetadata = fs.readFileSync(
    "build/TestCoins/package-metadata.bcs"
  );
  const moduleData = fs.readFileSync(
    "build/TestCoins/bytecode_modules/coins.mv"
  );
  // Deploy the contract
  let res = await client.publishPackage(
    account,
    new HexString(packageMetadata.toString("hex")).toUint8Array(),
    [
      new aptos.TxnBuilderTypes.Module(
        new HexString(moduleData.toString("hex")).toUint8Array()
      ),
    ],
  );
  await client.waitForTransaction(res);

  const moduleString = "0x895cff28180ccdd3746a22a5e8ff929060d4ae58510a97662d90339100ed75c7::coins"

  // Call a function on the contract to set a new message
  const payload = {
    function: moduleString + "::register_coins",
    type_arguments: [],
    arguments: [],
  };
  const txnRequest = await client.generateTransaction(
    account.address(),
    payload
  );
  const signedTxn = await client.signTransaction(account, txnRequest);
  const transactionRes = await client.submitTransaction(signedTxn);
  await client.waitForTransaction(transactionRes.hash);
}
