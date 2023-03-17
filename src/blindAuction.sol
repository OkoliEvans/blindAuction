// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

///@author Okoli Evans
///@title Blind auction contract
///@notice Takes bids for an NFT without revealing bids made by bidders,
///@notice Transfers the NFT to the highest bidder, refunds every other bidder
///@dev Keccak hash bids of each bidder and adds them to a map, retrives the highest bidder

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction {


    event Log(string _message);
    event NFTAdded(address _NFT, string _message);
    event refund(address _receiver, bool _success);
    event AddBeneficiary(address _beneficiary, string _message);
    event Bidded(address _bidder, string _message);
    event NftTransferred(
        address highestBidder_,
        address NFT_,
        uint32 tokenId_,
        string message_
    );
    event paidBeneficiary(
        address _beneficiary,
        uint256 _amount,
        string _message
    );
    event withdraw(address _to, uint256 _amt, string _msg);

    uint256 internal duration;
    uint256 startingPrice;
    uint32 internal startAt;
    uint32 internal endAt;
    uint32 tokenId;
    uint256 highestBid;

    bool auctionInSession;

    mapping(address => uint256) bidsToAccounts;
    address[] bidders;

    address NFT;
    address payable highestBidder;
    address payable Admin;
    address payable beneficiary;

    constructor() {
        Admin = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == Admin, "Unauthorized: Not Admin");
        _;
    }

    /// SET INITIAL VARIABLES AND VALUES
    function setStartPrice(
        uint256 _startingPrice
    ) public onlyOwner returns (uint256) {
        return startingPrice = _startingPrice;
    }

    function setStartTime(uint32 _start) internal onlyOwner returns (uint32) {
        return startAt = _start;
    }

    function setEndTime(uint32 _endTime) internal onlyOwner returns (uint32) {
        return endAt = _endTime;
    }

    function assignBeneficiary(address payable _beneficiary) public onlyOwner {
        if (_beneficiary == address(0)) {
            revert("Invalid address");
        }
        beneficiary = _beneficiary;

        emit AddBeneficiary(_beneficiary, "Beneficiary added succesfully...");
    }

    ///@dev Assuming the NFT to be auctioned is owned by third party Beneficiary
    function addNFT(address _NFT, uint32 _tokenId) public onlyOwner {
        if (_NFT == address(0)) {
            revert("Invalid NFT address");
        }
        tokenId = _tokenId;
        NFT = _NFT;

        IERC721(NFT).transferFrom(beneficiary, address(this), _tokenId);

        emit NFTAdded(_NFT, "NFT added successfully...");
    }

    function checkDuration() public returns (uint256) {
        return duration = endAt - startAt;
    }

    /// V2 CORE FUNCTIONS
    function startAuction(uint32 _start, uint32 _end) public onlyOwner {
        if (auctionInSession) {
            revert("Auction already in session");
        }
        if (_start <= 0) {
            revert("invalid time, enter valid time...");
        }
        if (_end <= _start) {
            revert("invalid time, enter valid time...");
        }
        if (startingPrice <= 0) {
            revert("Set start price");
        }
        setStartTime(_start);
        setEndTime(_end);
        auctionInSession = true;

        emit Log("Auction started");
    }

    function enterBid() public payable {
        if (!auctionInSession) {
            revert("Auction not open for bids yet, try again later");
        }
        if (msg.value < startingPrice) {
            revert("Amount is less than minimun price required to enter bid");
        }
        if (msg.sender == Admin) {
            revert("Not eligible to bid");
        }
        if (bidsToAccounts[msg.sender] > 0) {
            revert("Bid already submitted, cannot bid more than once");
        }
        (bool success, ) = payable(address(this)).call{value: startingPrice}(
            ""
        );
        require(success, "Transfer FAIL!");

        bidsToAccounts[msg.sender] = msg.value;
        bidders.push(msg.sender);
        emit Bidded(msg.sender, "Bid successful...");
    }

    function endAuction() internal {
        if (!auctionInSession) {
            revert("Auction already ended");
        }
        auctionInSession = false;
    }

    function pickWinner() internal returns (address) {
        if (bidders.length == 0) {
            revert("No bids yet...");
        }

        uint256 _highestBid;
        address _winner;

        for (uint32 i = 0; i < bidders.length; i++) {
            if (bidsToAccounts[bidders[i]] > _highestBid) {
                _winner = bidders[i];
                _highestBid = bidsToAccounts[_winner];
                highestBid = _highestBid;
                highestBidder = payable(_winner);
            }
        }
        return highestBidder;
    }

    function sendNFTtoHighestBidder() public onlyOwner {
        endAuction();
        pickWinner();

        IERC721(NFT).transferFrom(address(this), highestBidder, tokenId);

        emit NftTransferred(
            highestBidder,
            NFT,
            tokenId,
            "NFT transfer success!"
        );
    }

    function refundBidders() public payable onlyOwner {
        if (auctionInSession) {
            revert("Auction still ongoing");
        }
        if (bidders.length == 0) {
            revert("No bidders registered");
        }

        for (uint32 i = 0; i < bidders.length; i++) {
            if (bidders[i] != highestBidder) {
                // payable(bidders[i]).transfer(bidsToAccounts[bidders[i]]);
       
                bool success = payable(bidders[i]).send(bidsToAccounts[bidders[i]]);
                require(success, "Transfer FAIL!");
            }

            emit refund(bidders[i], true);
        }
    }

    function sendEthToBeneficiary() public payable onlyOwner {
        if (auctionInSession) {
            revert("Auction still ongoing...");
        }

        (bool success, ) = beneficiary.call{value: highestBid}("");
        require(success, "Failed to send Ether");

        emit paidBeneficiary(
            beneficiary,
            highestBid,
            "Beneficary paid successfully"
        );
    }

    function withdrawEth(address _to, uint256 _amt) public payable onlyOwner {
        if (_to == address(0)) {
            revert("Invalid address");
        }
        if (_amt <= 0) {
            revert("Invalid amount");
        }

        (bool success, ) = payable(_to).call{value: _amt}("");
        require(success, "Transfer FAIL!");
        emit withdraw(_to, _amt, "Withdraw Operation successful...");
    }

    receive() payable external {}

    fallback() payable external {}
}
