const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Stake = await ethers.getContractFactory("Stake");
  //Passing Starknet core contract address and Stake L2 address
  const stake = await Stake.deploy(
    "0xde29d060D45901Fb19ED6C6e959EB22d8626708e",
    "0x016b185c2475b72276c95f1a29592d238f0aeed71a91f51c57f817adc4cc4bbe" // L2 contract address
  );
  console.log("Stake smart contract address:", stake.address);

  const data_stake = {
    address: stake.address,
    abi: JSON.parse(stake.interface.format("json")),
  };

  if (!fs.existsSync("artifacts/ABI")) fs.mkdirSync("artifacts/ABI");
  fs.writeFileSync("artifacts/ABI/Stake.json", JSON.stringify(data_stake), {
    flag: "w",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
