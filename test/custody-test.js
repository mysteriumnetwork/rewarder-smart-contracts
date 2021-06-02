const { expect } = require("chai");

describe("Custody contract", function () {
  let token;
  let custody;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  before(async function () {
    // Get the ContractFactory and Signers here.
    const Token = await ethers.getContractFactory("Token");
    const Custody = await ethers.getContractFactory("Custody");
    const signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;

    token = await Token.deploy();
    custody = await Custody.deploy(token.address);
    await token.mint(custody.address, 10000000000);
  });

  // You can nest describe calls to create subsections.
  it("Should set the right owner", async function () {
    expect(await token.owner()).to.equal(owner.address);
  });

  it("Should allow to withdraw funds for owner", async function () {
    await custody.withdraw(1000, { from: owner.address });
    expect(await token.balanceOf(owner.address)).to.equal(1000);
  });

  it("Should authorize a given address", async function () {
    await custody.authorize(addr1.address);
    expect(await custody.authorized(addr1.address)).to.equal(true);
  });

  it("Should allow to withdraw funds for authorized address", async function () {
    await custody.connect(addr1).withdraw(1000);
    expect(await token.balanceOf(addr1.address)).to.equal(1000);
  });

  it("Should forbid a given address", async function () {
    await custody.forbid(addr1.address);
    expect(await custody.authorized(addr1.address)).to.equal(false);
  });

  it("Authorized should be able to payout", async function () {
    await custody.authorize(addr3.address);
    expect(await custody.authorized(addr3.address)).to.equal(true);
    const currentBalance = await token.balanceOf(addr1.address);

    await custody.connect(addr3).payout([addr1.address], [2000]);

    const updatedBalance = await token.balanceOf(addr1.address);
    expect(currentBalance).to.not.equal(updatedBalance);
  });

  it("Should transfer ownership", async function () {
    expect(await custody.authorized(token.owner())).to.equal(true);

    await custody.transferOwnership(addr2.address);
    expect(await custody.authorized(token.owner())).to.equal(false);
    expect(await custody.authorized(addr2.address)).to.equal(true);
    expect(await custody.owner()).to.equal(addr2.address);
  });

  it("Should reject withdraw funds for not authorized users / old owner", async function () {
    const initialBalance = await token.balanceOf(owner.address);

    await expect(custody.withdraw(1000)).to.be.revertedWith("Not authorized");
    expect(await token.balanceOf(owner.address)).to.equal(initialBalance);
  });
});
