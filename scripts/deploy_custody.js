const hre = require("hardhat");

async function deployCustody() {
  // Test Mysterium token (MYSTT) on Goerli testnet
  const tokenAddress = "0xf74a5ca65e4552cff0f13b116113ccb493c580c5";
  const ownerAddress = "NEW_OWNER";

  const Custody = await ethers.getContractFactory("Custody");

  const custody = await Custody.deploy(tokenAddress);
  await custody.deployed();
  console.log("Custody deployed to:", custody.address);

  await custody.transferOwnership(ownerAddress);
  console.log("Custody owner:", await custody.owner());
}

deployCustody()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
