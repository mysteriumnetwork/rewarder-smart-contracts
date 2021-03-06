// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Custody.sol";


contract Rewarder is Ownable {
    using MerkleProof for bytes32[];

    IERC20 public token;
    Custody public custody;
    mapping(uint256 => bytes32) public claimRoots;
    mapping(address => uint256) public totalPayoutsFor;
    uint256 public totalClaimed;
    uint256 public lastRootBlock;

    event RootUpdated(bytes32 root, uint256 blockNumber, uint256 _totalAmount);
    event Airdrop(uint256 totalDropped);
    event ClaimedChanged(uint256 totalUnclaimed);

    constructor(
                address _token,
                address payable _custody
                ) {
        token = IERC20(_token);
        custody = Custody(_custody);
        lastRootBlock = block.number;
        emit RootUpdated(0x0, block.number, 0);
    }

    function airdrop(address[] calldata _beneficiaries, uint256[] calldata _totalEarnings) external onlyOwner {
        require(_beneficiaries.length == _totalEarnings.length, "Invalid array length");

        uint256[] memory amounts = new uint256[](_totalEarnings.length);

        uint256 _total = 0;
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            address _beneficiary = _beneficiaries[i];
            uint256 _totalEarned = _totalEarnings[i];
            uint256 _totalReceived = totalPayoutsFor[_beneficiary];
            require(_totalEarned >= _totalReceived, "Invalid batch");
            uint256 _amount = _totalEarned - _totalReceived;

            if (_amount == 0) continue;

            amounts[i] = _amount;
            _total = _total + _amount;
            totalPayoutsFor[_beneficiary] = _totalEarned;
        }

        if (_total == 0) return;

        increaseClaimed(_total);
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            token.transfer(_beneficiaries[i], amounts[i]);
        }
        emit Airdrop(_total);
    }

    function updateRoot(bytes32 _claimRoot, uint256 _blockNumber, uint256 _totalReward) public onlyOwner {
        require(_blockNumber < block.number, "Given block number must be less than current block number");
        require(_blockNumber > lastRootBlock, "Given block number must be more than last root block");
        require(_totalReward > totalClaimed, "Total reward must be bigger than total claimed");

        uint256 _requiredTokens = _totalReward - totalClaimed;
        uint256 _currentBalance = token.balanceOf(address(this));
        if (_requiredTokens > _currentBalance) {
            custody.withdraw(_requiredTokens - _currentBalance);
        }

        lastRootBlock = _blockNumber;
        claimRoots[_blockNumber] = _claimRoot;
        emit RootUpdated(_claimRoot, _blockNumber, _totalReward);
    }

    function claim(address _recipient, uint256 _totalEarned, uint256 _blockNumber, bytes32[] calldata _proof) external {
        require(isValidProof(_recipient, _totalEarned, _blockNumber, _proof), "Invalid proof");

        uint256 _totalReceived = totalPayoutsFor[_recipient];
        require(_totalEarned >= _totalReceived, "Already paid");

        uint256 _amount = _totalEarned - _totalReceived;
        if (_amount == 0) return;

        totalPayoutsFor[_recipient] = _totalEarned;
        increaseClaimed(_amount);
        token.transfer(_recipient, _amount);
    }

    function isValidProof(address _recipient, uint256 _totalEarned, uint256 _blockNumber, bytes32[] calldata _proof) public view returns (bool) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        bytes32 leaf = keccak256(abi.encodePacked(_recipient, _totalEarned, chainId, address(this)));
        bytes32 root = claimRoots[_blockNumber];
        return _proof.verify(root, leaf);
    }

    function recoverTokens(IERC20 _erc20, address _to) public onlyOwner {
        require(address(_erc20) != address(token), "You can't recover default token");
        uint256 _balance = _erc20.balanceOf(address(this));
        _erc20.transfer(_to, _balance);
    }

    function increaseClaimed(uint256 delta) internal {
        totalClaimed = totalClaimed + delta;
        emit ClaimedChanged(totalClaimed);
    }
}
