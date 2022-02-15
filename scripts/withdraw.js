const hre = require("hardhat");

async function withdraw() {
  const custodyAddress = "0x40daF900e795F97d704F1CcD83588878d46d0288";
  const mystTokenAddress = "0x1379e8886a944d2d9d440b3d88df536aea08d9f3";

  const Token = await ethers.getContractFactory("Token");
  const Custody = await ethers.getContractFactory("Custody");

  const custody = await Custody.attach(custodyAddress);
  const mystToken = await Token.attach(mystTokenAddress);

  const mystBalance = await mystToken.balanceOf(custodyAddress);
  console.log("Will withdraw all balance:", mystBalance.toString());
  if (mystBalance == 0) {
    console.log("No money to withdraw, skipping");
    return;
  }

  await custody.withdraw(mystBalance);
  console.log("Withdraw complete");
}

withdraw()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
