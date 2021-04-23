require("@nomiclabs/hardhat-waffle");

const MNEMONIC = "amused glory ...";

module.exports = {
  defaultNetwork: "goerli",
  solidity: "0.8.3",
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://goerli.infura.io/v3/...",
      accounts: {
        mnemonic: MNEMONIC
      }
    }
  }
}