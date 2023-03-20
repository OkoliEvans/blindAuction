//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


import "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ENFT is ERC721 {

    constructor() ERC721("Evans NFT", "eNFT") {
        _mint(0x08c1AE7E46D4A13b766566033b5C47c735e19F6f, 1);
    }

}