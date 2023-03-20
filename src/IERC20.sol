//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ERC20 is IERC20 {

    function balanceOf(address owner) external view returns (uint256 balance);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}
