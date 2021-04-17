require("@nomiclabs/hardhat-waffle");

const MNEMONIC = "amused glory ...";

module.exports = {
  defaultNetwork: "goerli",
  solidity: "0.8.3",
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://goerli.infura.io/v3/048b64dd20b7446e9f0ce3a4c79ea13d",
      accounts: {
        mnemonic: MNEMONIC
      }
    }
  }
}