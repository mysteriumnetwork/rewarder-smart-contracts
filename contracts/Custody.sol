// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract Custody is Ownable {
    using Address for address;

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        authorized[owner()] = true;
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

    receive() external payable {}

    function withdraw(address token, uint256 amount) onlyAuthorized public {
        IERC20(token).transfer(msg.sender, amount);
    }
}
