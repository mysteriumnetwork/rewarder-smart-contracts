const hre = require("hardhat");

async function transfer() {
  const rewarderAddress = "0x9799Be613DFa2ab4E971E6fBA51630c77D526Bb7";
  const ownerAddress = "NEW_OWNER";

  const Rewarder = await ethers.getContractFactory("Rewarder");
  const rewarder = await Rewarder.attach(rewarderAddress);

  console.log(
    "Changing owner from:",
    await rewarder.owner(),
    "to:",
    ownerAddress
  );

  await rewarder.transferOwnership(ownerAddress);
  console.log("New owner:", ownerAddress);
}

transfer()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
