// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract Custody is Ownable {
    using Address for address;

    mapping(address => bool) public authorized;
    IERC20 public token;

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        authorized[owner()] = true;
    }

    // Reject any ethers sent to this smart-contract
    receive() external payable {
        revert("Rejecting tx with ethers sent");
    }

    function authorize(address _account) public onlyOwner {
        authorized[_account] = true;
    }

    function forbid(address _account) public onlyOwner {
        require(_account != owner(), "Owner access cannot be forbidden!");

        authorized[_account] = false;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        authorized[owner()] = false;
        super.transferOwnership(newOwner);
        authorized[owner()] = true;
    }

    function withdraw(uint256 amount) onlyAuthorized public {
        token.transfer(msg.sender, amount);
    }

    // Allow to withdraw any arbitrary token, should be used by
    // contract owner to recover accidentally received funds.
    function recover(address _tokenAddress, uint256 amount) onlyOwner public {
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    // Allows to withdraw funds into many addresses in one tx
    // (or to do mass bounty payouts)
    function payout(address[] calldata _recipients, uint256[] calldata _amounts) onlyOwner public {
        require(_recipients.length == _amounts.length, "Invalid array length");

        for (uint256 i = 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], _amounts[i]);
        }
    }
}
