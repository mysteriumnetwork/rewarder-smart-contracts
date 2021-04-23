const hre = require("hardhat");

async function main() {
  // Test Mysterium token (MYSTT) on Goerli testnet
  const tokenAddress = "0xf74a5ca65e4552cff0f13b116113ccb493c580c5";
  const ownerAddress = "0x3ec4a6356de5a0403e59fabdc76dc0845b271760";

  // Get the ContractFactory here.
  const Custody = await ethers.getContractFactory("Custody");
  const Rewarder = await ethers.getContractFactory("Rewarder");

  // Deploying contracts
  const custody = await Custody.deploy(tokenAddress);
  await custody.deployed();
  console.log("Custody deployed to:", custody.address);

  rewarder = await Rewarder.deploy(tokenAddress, custody.address);
  await rewarder.deployed();
  console.log("Rewarder deployed to:", rewarder.address);

  // Authorize rewarder for custody withdrawals
  await custody.authorize(rewarder.address);
  console.log("Rewarder is authorized:", await custody.authorized(rewarder.address));

  // Transfer ownership to the proper owner
  await custody.transferOwnership(ownerAddress);
  console.log("Custody owner:", await custody.owner());

  await rewarder.transferOwnership(ownerAddress);
  console.log("Rewarder owner:", await rewarder.owner());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
