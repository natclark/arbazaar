// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title Template NFT. */
contract TemplateNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address arbazaar;

    /** @dev Creates an NFT collection that pre-approves minted tokens for trading on Arbazaar.
      * @param _arbazaar The canonical Arbazaar contract address.
      * @param _name The name of the collection.
      * @param _symbol The symbol of the collection.
      */
    constructor(
        address _arbazaar,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        arbazaar = _arbazaar;
    }

    /** @dev Creates a token, adds it to the collection, and increments the token ID.
      * @param _metadata The metadata URI that the item should point to.
      */
    function createToken(
        string memory _metadata
    ) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _metadata);
        setApprovalForAll(arbazaar, true);
        return newItemId;
    }
}