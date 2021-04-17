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

- Custody smart contract:
[0xF4eec243A31ed1a8C19009648E615686597FF825](https://goerli.etherscan.io/address/0xF4eec243A31ed1a8C19009648E615686597FF825)

- Hermes smart contract:
[0x52f50139892611515586007c26e31e6751F78a1D](https://goerli.etherscan.io/address/0x52f50139892611515586007c26e31e6751F78a1D)

- MYSTTv2 Token: [0xf74a5ca65E4552CfF0f13b116113cCb493c580C5](https://goerli.etherscan.io/address/0xf74a5ca65E4552CfF0f13b116113cCb493c580C5)