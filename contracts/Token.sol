// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address public owner;

    constructor () ERC20("Test Mysterium token", "MYSTT") {
        owner = msg.sender;
    }

    function mint(address _account, uint _amount) public {
        _mint(_account, _amount);
    }
}
