import { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-ethers";
import "solidity-coverage";
import "@nomiclabs/hardhat-ganache";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-gas-reporter";
import "dotenv/config";
import "solidity-docgen";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";
import "@typechain/hardhat"
import "@nomiclabs/hardhat-waffle";


const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.19',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {},
    localhost: {
      chainId: 1337,
      // url: process.env.ETH_NETWORK_URL || "http://host.docker.internal:8545",
      // accounts: [
      //   process.env.OWNER_KEY as string
      // ],
      // },
      // development: {
      //   chainId: 1234,
      //   url: process.env.ETH_NETWORK_URL || "",
      //   accounts: [
      //     process.env.OWNER_KEY as string
      //   ],
      // },
      // staging: {
      //   chainId: 456,
      //   url: process.env.ETH_NETWORK_URL || "",
      //   accounts: [
      //     process.env.OWNER_KEY as string
      //   ],
    }
    //   production: {
    //     chainId: 789,
    //     url: process.env.ETH_NETWORK_URL || "",
    //     accounts: [
    //       process.env.OWNER_KEY as string
    //     ],
    // },
  },
  docgen: {
    pages: 'items'
  },
  // abiExporter: {
  //   runOnCompile: true,
  //   clear: true,
  //   only: ['contracts/*']
  // }
};

export default config;

