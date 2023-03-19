// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/blindAuction.sol";
import "../src/IENFT.sol";

contract AuctionTest is Test {
    Auction public auction;
    // IENFT internal BAYC = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    address BAYC = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address  BAYC_holder = 0x08c1AE7E46D4A13b766566033b5C47c735e19F6f;
    uint32 tokenId = 9547;
    uint256 startPrice = (2 ether);
    // nftAuction.startAuction(1679042970, 1679142970);
    //  await nftAuction.addNFT(BAYC, 9547);
    event Log(string message_);

    function setUp() public {
        auction = new Auction();
    }



    function testapprove() public {
        vm.prank(BAYC_holder);
        IENFT(BAYC).approve(address(auction), tokenId);   
        emit Log("approval successful...");
    }

    
    function testAddNft() public {
        testapprove();
        auction.addNFT( BAYC, payable(BAYC_holder) ,tokenId);
    }


    function testStartAuction() public {
        testapprove();
        testAddNft();
        auction.startAuction( startPrice, 1679348198, 1689142970);
    }




}
