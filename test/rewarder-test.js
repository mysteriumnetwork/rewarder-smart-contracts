const { expect } = require("chai");
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

describe("Rewarder contract", function () {
    let token;
    let token2;
    let custody;
    let rewarder;
    let owner;
    let addr1;
    let addr2;
    let addrs;
    let chainId;


    before(async function () {
        // Get the ContractFactory and Signers here.
        const Token = await ethers.getContractFactory("Token");
        const Custody = await ethers.getContractFactory("Custody");
        const Rewarder = await ethers.getContractFactory("Rewarder");
        const signers = await ethers.getSigners();
        [owner, addr1, addr2, ...addrs] = signers;

        chainId = await owner.getChainId();
        token = await Token.deploy();
        token2 = await Token.deploy();
        custody = await Custody.deploy(token.address);
        rewarder = await Rewarder.deploy(token.address, custody.address);

        await token.mint(custody.address, 100000000000);
    });

    it("Should set correct init params", async function () {
        expect(await rewarder.custody()).to.equal(custody.address);
        expect(await rewarder.token()).to.equal(token.address);
        expect(await rewarder.lastRootBlock()).to.be.at.least(1);
    });

    it("Should authorize rewarder for withdrawal", async function () {
        await custody.authorize(rewarder.address);
        expect(await custody.authorized(rewarder.address)).to.equal(true);
    });

    it("Should update root and allow to claim for one address", async function () {
        // Produce a merkle tree with a single leaf node which will be our addr1.
        const amount = 1000;
        const leaf1 = ethers.utils.solidityKeccak256(['address', 'uint256', 'uint256', 'address'], [addr1.address, amount, chainId, rewarder.address]);
        const tree = new MerkleTree([leaf1], keccak256, { sort: true });

        expect(await token.balanceOf(rewarder.address)).to.equal(0);
        const currentBlock = await rewarder.lastRootBlock();
        await hre.network.provider.send("evm_mine");
        const newBlock = currentBlock.add(1);

        const currentBlockRoots = await rewarder.claimRoots(newBlock);
        const hexRoot = tree.getHexRoot();

        await rewarder.updateRoot(hexRoot, newBlock, amount * 2);
        // Check that rewarder contract was updated after updating root.
        expect(await token.balanceOf(rewarder.address)).to.equal(amount * 2);
        expect(await rewarder.lastRootBlock()).to.equal(newBlock);
        expect(await rewarder.claimRoots(newBlock)).to.not.equal(currentBlockRoots);

        // Check that we have no balance on the address we're able to use for claimming.
        expect(await token.balanceOf(addr1.address)).to.equal(0);
        expect(await rewarder.totalClaimed()).to.equal(0);
        const proof = tree.getHexProof(leaf1);
        await rewarder.claim(addr1.address, amount, newBlock, proof);

        // After claiming we should have the whole claimed amount and totalclaimed should be updated.
        expect(await token.balanceOf(addr1.address)).to.equal(amount);
        expect(await rewarder.totalClaimed()).to.equal(amount);
    });

    it("Should update root and do an airdrop for two addresses", async function () {
        // Produce a merkle tree with a two leaf nodes which will be our addr1 and addr2.
        // We will do an airdrop for both of them.
        const amount = 2000;
        const leaf1 = ethers.utils.solidityKeccak256(['address', 'uint256', 'uint256', 'address'], [addr1.address, amount, chainId, rewarder.address]);
        const leaf2 = ethers.utils.solidityKeccak256(['address', 'uint256', 'uint256', 'address'], [addr2.address, amount, chainId, rewarder.address]);
        const tree = new MerkleTree([leaf1, leaf2], keccak256, { sort: true });

        const currentBlock = await rewarder.lastRootBlock();
        await hre.network.provider.send("evm_mine");
        const newBlock = currentBlock.add(1);

        const currentBlockRoots = await rewarder.claimRoots(newBlock);
        const hexRoot = tree.getHexRoot();

        // Check that rewarder contract was updated after updating root.
        await rewarder.updateRoot(hexRoot, newBlock, amount * 2);
        expect(await token.balanceOf(rewarder.address)).to.equal(amount * 2);
        expect(await rewarder.lastRootBlock()).to.equal(newBlock);
        expect(await rewarder.claimRoots(newBlock)).to.not.equal(currentBlockRoots);

        // Do the airdrop and check that both balances have been updated to the correct amount.
        await rewarder.airdrop([addr1.address, addr2.address], [amount, amount]);
        // eventhough addr1 already had 1000, it's balance should be equal to amount paid out. It should not be added total balance.
        expect(await token.balanceOf(addr1.address)).to.equal(amount);
        expect(await token.balanceOf(addr2.address)).to.equal(amount);

        // Total claimed is equal to both addresses claimed amount sum
        const totalClaimed = await rewarder.totalClaimed();
        expect(totalClaimed).to.equal(amount * 2);
    });

    it("Should should allow to recover tokens", async function () {
        const token2Balance = await token2.balanceOf(rewarder.address);

        await token2.mint(rewarder.address, 1000);
        await rewarder.recoverTokens(token2.address, owner.address, 1000);

        // Tokens should be returned to the owner and removed from rewarder.
        expect(await token2.balanceOf(rewarder.address)).to.equal(0);
        expect(await token2.balanceOf(owner.address)).to.equal(1000);
    });
});

