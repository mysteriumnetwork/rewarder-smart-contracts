// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./Custody.sol";

contract Rewarder is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using MerkleProof for bytes32[];

  IERC20 public token;
  Custody public custody;
  mapping(uint256 => bytes32) public claimRoots;
  mapping(address => uint256) public totalPayoutsFor;
  mapping(address => bool) public banlist;
  uint256 public lastBlockNumber;
  uint256 public lastBlocksPeriod;
  uint256 public pricePerBlock;
  uint256 public totalUnclaimed;
  uint256 public deployBlock;
  uint256 public lastRootBlock;

  event RewarderDeployed(uint256 tokenStart, address uniswapPair);
  event PriceUpdated(uint256 pricePerBlock, uint256 blocksPeriod);
  event RootUpdated(bytes32 root, uint256 blockNumber);
  event UnclaimedChanged(uint256 totalUnclaimed);
  event Airdrop(uint256 totalDropped);
  event BanChanged(address account, bool banned);

  constructor(
    address _token,
    address payable _custody,
    address _uniswapPair,
    uint256 _tokenStart
  ) {
    token = IERC20(_token);
    custody = Custody(_custody);
    deployBlock = block.number;
    lastBlockNumber = block.number;
    lastRootBlock = block.number;
    emit RewarderDeployed(_tokenStart, _uniswapPair);
    emit RootUpdated(0x0, block.number);
    _doBan(_custody, true);
  }

  function airdrop(address[] calldata beneficiaries, uint256[] calldata totalEarnings) external onlyOwner {
    require(beneficiaries.length == totalEarnings.length, "Invalid array length");

    uint256[] memory amounts = new uint256[](totalEarnings.length);

    uint256 total = 0;
    for (uint256 i = 0; i < beneficiaries.length; i++) {
      address beneficiary = beneficiaries[i];
      uint256 totalEarned = totalEarnings[i];
      uint256 totalReceived = totalPayoutsFor[beneficiary];
      require(totalEarned >= totalReceived, "Invalid batch");
      uint256 amount = totalEarned.sub(totalReceived);

      if (amount == 0) continue;

      amounts[i] = amount;
      total = total.add(amount);
      totalPayoutsFor[beneficiary] = totalEarned;
    }

    if (total == 0) return;

    decreaseUnclaimed(total);
    for (uint256 i = 0; i < beneficiaries.length; i++) {
      token.safeTransfer(beneficiaries[i], amounts[i]);
    }
    emit Airdrop(total);
  }

  function updatePrice(uint256 newPricePerBlock, uint256 blocksPeriod) public onlyOwner {
    uint256 blocksPassed = block.number.sub(lastBlockNumber);

    uint256 tokensToReturn;
    if (blocksPassed < lastBlocksPeriod) {
      tokensToReturn = lastBlocksPeriod.sub(blocksPassed).mul(pricePerBlock);
    }
    uint256 totalReward = newPricePerBlock.mul(blocksPeriod);

    if (totalReward > tokensToReturn) {
      uint256 toWithdraw = totalReward.sub(tokensToReturn);
      increaseUnclaimed(toWithdraw);
      custody.withdraw(address(token), toWithdraw);
    } else if (totalReward < tokensToReturn) {
      uint256 toDeposit = tokensToReturn.sub(totalReward);
      decreaseUnclaimed(toDeposit);
      token.safeTransfer(address(custody), toDeposit);
    }

    pricePerBlock = newPricePerBlock;
    lastBlockNumber = block.number;
    lastBlocksPeriod = blocksPeriod;

    emit PriceUpdated(newPricePerBlock, blocksPeriod);
  }

  function updateRoot(bytes32 claimRoot, uint256 blockNumber) public onlyOwner {
    require(blockNumber < block.number, "Invalid block number");
    require(lastRootBlock < blockNumber, "Invalid block number");

    lastRootBlock = blockNumber;
    claimRoots[blockNumber] = claimRoot;
    emit RootUpdated(claimRoot, blockNumber);
  }

  function claim(address recipient, uint256 totalEarned, uint256 blockNumber, bytes32[] calldata proof) external {
    require(isValidProof(recipient, totalEarned, blockNumber, proof), "Invalid proof");

    uint256 totalReceived = totalPayoutsFor[recipient];
    require(totalEarned >= totalReceived, "Already paid");

    uint256 amount = totalEarned.sub(totalReceived);
    if (amount == 0) return;

    totalPayoutsFor[recipient] = totalEarned;
    decreaseUnclaimed(amount);
    token.safeTransfer(recipient, amount);
  }

  function isValidProof(address recipient, uint256 totalEarned, uint256 blockNumber, bytes32[] calldata proof) public view returns (bool) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    bytes32 leaf = keccak256(abi.encodePacked(recipient, totalEarned, chainId, address(this)));
    bytes32 root = claimRoots[blockNumber];
    return proof.verify(root, leaf);
  }

  function recoverTokens(IERC20 erc20, address to, uint256 amount) public onlyOwner {
    uint256 balance = erc20.balanceOf(address(this));

    if (address(erc20) == address(token)) {
      balance = balance.sub(totalUnclaimed);
    }

    require(balance >= amount, "Given amount is larger than recoverable balance");
    erc20.safeTransfer(to, amount);
  }

  function ban(address account) public onlyOwner {
    _doBan(account, true);
  }

  function unban(address account) public onlyOwner {
    require(account != address(custody), "Custody address");
    _doBan(account, false);
  }

  function _doBan(address _account, bool _ban) internal {
    banlist[_account] = _ban;
    emit BanChanged(_account, _ban);
  }

  function increaseUnclaimed(uint256 delta) internal {
    totalUnclaimed = totalUnclaimed.add(delta);
    emit UnclaimedChanged(totalUnclaimed);
  }

  function decreaseUnclaimed(uint256 delta) internal {
    totalUnclaimed = totalUnclaimed.sub(delta);
    emit UnclaimedChanged(totalUnclaimed);
  }
}