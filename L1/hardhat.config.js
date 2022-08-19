require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: "./.env" });
require("hardhat-gas-reporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000000,
      },
    },
  },
  networks: {
    myNetwork: {
      url: "http://localhost:5000",
    },
    goerli: {
      url: process.env.ALCHEMY_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
