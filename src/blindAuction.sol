// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

///@author Okoli Evans
///@title Blind auction contract
///@notice Takes bids for an NFT without revealing bids made by bidders,
///@notice Transfers the NFT to the highest bidder, refunds every other bidder
///@dev Keccak hash bids of each bidder and adds them to a map, retrives the highest bidder

contract Auction {
    event Log(address _bidder, bool _bidSuccess);
    event NFTAdded(address _NFT, string _message);
    event refund(address _receiver, bool _success);
    event AddAuctioneer(address _auctioneer, string _message);

    uint256 internal duration;
    uint32 internal startAt;
    uint32 internal endAt;
    uint256 highestBid;
    uint256 startingPrice;

    bool started;
    bool ended;

    mapping(address => uint256) bidsToAccounts;

    address NFT;
    address highestBidder;
    address Admin;
    address auctioneer;

    constructor() {
        Admin = msg.sender;
    }

    modifier onlyOwner() {
        require(Admin == msg.sender, "Unauthorized: Not Admin");
        _;
    }

    modifier onlyAuctioneer() {
        require(auctioneer, "Unauthorized: Not Auctioneer");
        _;
    }

    function setStartPrice(uint256 _startingPrice) public onlyOwner returns(uint256) {
        return startingPrice = _startingPrice;
    }

    function setStartTime(uint32 _start) public onlyOwner returns(uint32) {
        return startAt = _start;
    }

    function setEndTime(uint32 _endTime) public onlyOwner returns(uint32) {
        return endAt = _endTime;
    }

    function assignAuctioneer(address _auctioneer) public onlyOwner{
        if(_auctioneer == address(0)) { revert("Invalid address");}
        auctioneer = _auctioneer;

        emit AddAuctioneer(_auctioneer, "Auctioneer added succesfully...");
    }

    function addNFT(address _NFT) public onlyOwner {
        if(_NFT == address(0)) {revert("Invalid NFT address");}
        NFT = _NFT;

        emit NFTAdded(_NFT, "NFT added successfully...");
    }

}


















