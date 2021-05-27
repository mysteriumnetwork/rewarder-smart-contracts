const hre = require("hardhat");

async function transferCustody() {
  const custodyAddress = "0xdcEF91A78039203c92A3A02786def283b20d9f40";
  const ownerAddress = "NEW_OWNER";

  const Custody = await ethers.getContractFactory("Custody");
  const custody = await Custody.attach(custodyAddress);

  console.log(
    "Changing owner from:",
    await custody.owner(),
    "to:",
    ownerAddress
  );

  await custody.transferOwnership(ownerAddress);
  console.log("New owner:", ownerAddress);
}

transferCustody()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
