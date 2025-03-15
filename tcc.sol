// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title The Calico Coin
/// @author Jorge López Pellicer
/// @dev https://www.linkedin.com/in/jorge-lopez-pellicer/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TheCalicoCoin is ERC20 {
    constructor() ERC20("The Calico Coin", "TCC") {
        _mint(msg.sender, 10_000_000_000 * 10 ** 18);
    }
}
