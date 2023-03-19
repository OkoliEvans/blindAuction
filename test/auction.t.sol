// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/blindAuction.sol";
import "../src/IENFT.sol";

contract AuctionTest is Test {
    Auction public auction;

    function setUp() public {
        auction = new Auction();
    }

    
    function testAddNft() public {
        auction.addNFT();
    };


}
