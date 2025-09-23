// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {

    constructor(uint256 initialSupply) ERC20("MyERC20", "MYERC20") {
        _mint(msg.sender, initialSupply);
    }
} 