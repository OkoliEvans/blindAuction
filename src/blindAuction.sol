// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

///@author Okoli Evans
///@title Blind auction contract
///@notice Takes bids for an NFT without revealing bids made by bidders,
///@notice Transfers the NFT to the highest bidder, refunds every other bidder
///@dev Keccak hash bids of each bidder and adds them to a map, retrives the highest bidder

contract Auction {
    event Log(string _message);
    event NFTAdded(address _NFT, string _message);
    event refund(address _receiver, bool _success);
    event AddBeneficiary(address _beneficiary, string _message);
    event Bidded(address _bidder, string _message);

    uint256 internal duration;
    uint32 internal startAt;
    uint32 internal endAt;
    uint256 highestBid;
    uint256 startingPrice;

    bool auctionInSession;

    mapping(address => uint256) bidsToAccounts;

    address NFT;
    address payable highestBidder;
    address payable Admin;
    address payable beneficiary;

    constructor() {
        Admin = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(Admin == msg.sender, "Unauthorized: Not Admin");
        _;
    }

    /// SET INITIAL VARIABLES AND VALUES
    function setStartPrice(uint256 _startingPrice) public onlyOwner returns(uint256) {
        return startingPrice = _startingPrice;
    }

    function setStartTime(uint32 _start) internal onlyOwner returns(uint32) {
        return startAt = _start;
    }

    function setEndTime(uint32 _endTime) public onlyOwner returns(uint32) {
        return endAt = _endTime;
    }

    function assignBeneficiary(address payable _beneficiary) public onlyOwner{
        if(_beneficiary == address(0)) { revert("Invalid address");}
        beneficiary = _beneficiary;

        emit AddBeneficiary(_beneficiary, "Beneficiary added succesfully...");
    }

    function addNFT(address _NFT) public onlyOwner {
        if(_NFT == address(0)) {revert("Invalid NFT address");}
        NFT = _NFT;

        emit NFTAdded(_NFT, "NFT added successfully...");
    }

    function checkDuration() public returns(uint256) {
        return duration = endAt - startAt;
    }

    /// V2 CORE FUNCTIONS
    function startAuction(uint32 _start, uint32 _end) public onlyOwner {
        if(auctionInSession){ revert("Auction already in session"); }
        if (_start <= 0) { revert("invalid time, enter valid time...");}
        if(startingPrice <= 0) { revert("Set start price");}
        setStartTime(_start);
        setEndTime(_end);
        auctionInSession = true;

        emit Log("Auction started");
    }

    function enterBid() public payable {
        if(!auctionInSession){ revert("Auction not open for bids yet, try again later"); }
        if(msg.value < startingPrice) {revert("Amount is less than minimun price required to enter bid");}
        (bool success, ) = payable(address(this)).call{value: startingPrice}("");
        require(success, "Transfer FAIL!");

        bidsToAccounts[msg.sender] = msg.value;
        emit Bidded(msg.sender, "Bid successful...");
    }



}


















