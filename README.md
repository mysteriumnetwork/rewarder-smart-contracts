# Smart contracts for Mysterium Network bounty rewards

This is a set of smart contracts which allow Mysterium team securelly pay exit node bounty and affiliate program rewards. Users who gets rewards will be able to claim them at any time. If they decide not to claim righ after rewards are calculated (e.g. once in a week) then next time they will claim accumulated rewards for both periods at once.

This approach also allows to reduce blockchain transaction fees for both Mysterium team and users while giving bigger flexibility (e.g. possibility to do payouts each weeek instead of once in a month). This

This is also more trustless way for reward distribution (and more similar to how it will work on MainNet). Once rewards are distributed (added new merkle root into blockchain), team can't take them back, even if user is not claiming them for very long time.

There are two main smart contracts:

- `Custody.sol` which holds bigger amount of tokens which will be used in future payouts.
- `Rewarder.sol` holds main payout and rewards claiming logic. Each time during reward distribution there will be sent new merkle tree root and users will get merkle proofs (via off-chain channels, e.g. in node or affiliate dashboards) which allows to claim rewards.

## Setup and test

We're using truffle for smart contract compilation and running tests.

1. Install dependencies

```bash
npm install
```

2. Run tests

```bash
npm test
```

3. Testing deployment (into Görli testnet)

First you should add own mnemonic into `hardhat.config.js` from which ethereum accounts and private keys will be created. Then simply run:

```bash
npx hardhat run --network goerli scripts/deploy.js
```

## Current deployment (ethereum Görli testnet)

### Goerli

- Custody smart contract:
  [0xa0cFb3B6869CB3dF6876aa95bc8603F24f47a853](https://goerli.etherscan.io/address/0xF4eec243A31ed1a8C19009648E615686597FF825)

- Rewarder smart contract:
  [0x011305BA8B9442D167377DC0BD77C4da79c8e6f1](https://goerli.etherscan.io/address/0x011305BA8B9442D167377DC0BD77C4da79c8e6f1)

- MYSTTv2 Token: [0xf74a5ca65E4552CfF0f13b116113cCb493c580C5](https://goerli.etherscan.io/address/0xf74a5ca65E4552CfF0f13b116113cCb493c580C5)

### Matic (mainnet)

- Custody smart contract: [0x40daF900e795F97d704F1CcD83588878d46d0288](https://polygon-explorer-mainnet.chainstacklabs.com/address/0x40daF900e795F97d704F1CcD83588878d46d0288)

- Rewarder smart contract:
  [0x9799Be613DFa2ab4E971E6fBA51630c77D526Bb7](https://polygon-explorer-mainnet.chainstacklabs.com/address/0x9799Be613DFa2ab4E971E6fBA51630c77D526Bb7)
  
### Topperupper
  
- **Goerli** Custody smart contract: [0xdcEF91A78039203c92A3A02786def283b20d9f40](https://goerli.etherscan.io/address/0xdcEF91A78039203c92A3A02786def283b20d9f40)
- **Mainnet** Custody smart contract: [0x9722EBf15ABc714882c07aFa4D4fdCBE36C7A6ED](https://etherscan.io/address/0x9722EBf15ABc714882c07aFa4D4fdCBE36C7A6ED)
