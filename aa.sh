main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOL
echo "mint.js script created."

echo "Minting tokens..."
npx hardhat run scripts/mint.js --network swisstronik
echo "Tokens minted."

echo "Creating transfer.js script..."
cat <<EOL > scripts/transfer.js
const hre = require("hardhat");
const fs = require("fs");
const { encryptDataField, decryptNodeResponse } = require("@swisstronik/utils");

const sendShieldedTransaction = async (signer, destination, data, value) => {
  const rpcLink = hre.network.config.url;
  const [encryptedData] = await encryptDataField(rpcLink, data);
  return await signer.sendTransaction({
    from: signer.address,
    to: destination,
    data: encryptedData,
    value,
  });
};

async function main() {
  const contractAddress = fs.readFileSync("contract.txt", "utf8").trim();
  const [signer] = await hre.ethers.getSigners();
  const contractFactory = await hre.ethers.getContractFactory("PERC20Sample");
  const contract = contractFactory.attach(contractAddress);
  const functionName = "transfer";
  const amount = 1 * 10 ** 18;
  const functionArgs = ["0x16af037878a6cAce2Ea29d39A3757aC2F6F7aac1", amount.toString()];
  const transaction = await sendShieldedTransaction(
    signer,
    contractAddress,
    contract.interface.encodeFunctionData(functionName, functionArgs),
    0
  );
  await transaction.wait();
  console.log("Transaction Response: ", \Transfer token has been success! Transaction hash: https://explorer-evm.testnet.swisstronik.com/tx/\${transaction.hash}\);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
EOL
echo "transfer.js script created."

echo "Transferring tokens..."
npx hardhat run scripts/transfer.js --network swisstronik
echo "Tokens transferred."
echo "Done! Subscribe: https://t.me/feature_earning"
