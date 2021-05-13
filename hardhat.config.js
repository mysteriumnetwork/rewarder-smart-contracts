require("@nomiclabs/hardhat-waffle");

const MNEMONIC = "amused glory ...";

module.exports = {
  defaultNetwork: "hardhat",
  solidity: "0.8.3",
  networks: {
    hardhat: {},
    goerli: {
      url: "https://goerli.infura.io/v3/...",
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
    matic: {
      url: "https://rpc-mainnet.maticvigil.com/v1/...",
      chainId: 137,
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
  },
};
