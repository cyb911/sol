// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "./ERC721.sol";
import {Ownable} from "../../access/Ownable.sol";

contract MyNFT is ERC721,Ownable {
    uint256 private _nextTokenId;

    // 
    constructor() ERC721("My NFT", "MFN") Ownable(msg.sender) {}
    
    // 铸造NFT功能
    function mintNFT(address to, string memory tokenURI_) external onlyOwner returns (uint256) {
        require(to != address(0), "ERC721: mint to the zero address");

        _nextTokenId += 1;
        uint256 newTokenId = _nextTokenId;

        _mint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI_);

        return newTokenId;
    }

}