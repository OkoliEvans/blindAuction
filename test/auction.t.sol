// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/blindAuction.sol";
// import "../src/IENFT.sol";
// import "../src/IERC20.sol";
import "../src/eNft.sol";

contract AuctionTest is Test {
    Auction public auction;
    ENFT public eNft;

    // address eNftAddress = 0x2e234DAe75C793f67A35089C9d99245E1C58470b;
    // address BAYC = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    // address BAYC_holder = 0x08c1AE7E46D4A13b766566033b5C47c735e19F6f;

    address ENFT_holder = 0x08c1AE7E46D4A13b766566033b5C47c735e19F6f;
    address Eth_holder1 = 0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8;
    address Eth_holder2 = 0x828b154032950C8ff7CF8085D841723Db2696056;

    // uint32 tokenId = 9547;
    uint32 tokenId = 1;
    uint256 startPrice = (2 ether);

    // EVENTS
    event Log(string message_);

    // UNIT TESTS
    function setUp() public {
        auction = new Auction();
        eNft = new ENFT();
    }

    function testGetNftAddress() public view {
        auction.getENftAddress(address(eNft));
    }


    function testapprove() public {
        vm.prank(ENFT_holder);
        eNft.approve(address(auction), tokenId);
        emit Log("approval successful...");
    }

    
    function testAddNft() public {
        testapprove();
        vm.deal( msg.sender, 5 ether);
        auction.addNFT(address(eNft), payable(ENFT_holder), tokenId);
    }


    // function testStartAuction() public {
    //     testapprove();
    //     testAddNft();
    // }

    // function testEnterBid() public {

    //     vm.prank(Eth_holder1);
    //     auction.enterBid(4 ether);
    // }



}
