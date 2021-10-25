// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title Arbazaar. */
contract Arbazaar is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listings;
    Counters.Counter private _sales;
    Counters.Counter private _offers;

    address payable deployerAddress;
    address payable developerWallet;

    address tokenAddress;
    IERC20 public buckToken;

    uint public tokens;
    uint public rewardsAll;
    uint public rewardsUnclaimed;
    address[] public stakers;

    uint totalVolume;
    uint totalFees;

    mapping(address => uint) public stake;
    mapping(address => uint) public unclaimedRewards;
    mapping(address => uint) public claimedRewards;
    mapping(address => uint) public collectionVolume;
    mapping(address => bool) public isStaker;
    mapping(address => bool) public isStaking;

    /** @dev Creates an NFT marketplace on Arbitrum.
      * @param _developerWallet The address of the developer wallet.
      * @param _buckTokenAddress The canonical BUCK token address.
      */
    constructor(
        address payable _developerWallet,
        address _buckTokenAddress
    ) {
        deployerAddress = payable(msg.sender);
        developerWallet = _developerWallet;
        tokenAddress = _buckTokenAddress;
        buckToken = IERC20(tokenAddress);
    }

    struct Listing {
        uint listingKey;
        address collection;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        uint precision;
        bool sold;
        bool cancelled;
        uint date;
    }

    mapping(uint => Listing) private listing;

    event ListingAdded(
        uint indexed listingKey,
        address indexed collection,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        uint precision,
        bool sold,
        bool cancelled,
        uint date
    );

    event ListingRemoved(
        uint indexed listingKey,
        address indexed collection,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        uint precision,
        bool sold,
        bool cancelled,
        uint date
    );

    struct Offer {
        uint offerKey;
        address collection;
        uint tokenId;
        address payable bidder;
        uint price;
        uint precision;
        bool sold;
        bool cancelled;
        uint date;
    }

    mapping(uint => Offer) private offer;

    event OfferAdded(
        uint indexed offerKey,
        address indexed collection,
        uint indexed tokenId,
        address bidder,
        uint price,
        uint precision,
        bool sold,
        bool cancelled,
        uint date
    );

    event OfferRemoved(
        uint indexed offerKey,
        address indexed collection,
        uint indexed tokenId,
        address bidder,
        uint price,
        uint precision,
        bool sold,
        bool cancelled,
        uint date
    );

    /** @dev Calculates the fee paid out to stakers, provided a given sale.
      * @param _value The total value of the given sale.
      * @param _precision The precision with which to manipulate _value, to prevent overflow/underflow.
      * @return 2% of _value.
      */
    function calculateStakerFee(
        uint _value,
        uint _precision
    ) internal pure returns(uint) {
        if (_precision == 15) {
            return (_value / 1e15) * (20 * 1e12);
        } else if (_precision == 16) {
            return (_value / 1e16) * (20 * 1e13);
        } else if (_precision == 17) {
            return (_value / 1e17) * (20 * 1e14);
        } else {
            return (_value / 1e18) * (20 * 1e15);
        }
    }

    /** @dev Calculates the fee paid out to the developer, provided a given sale.
      * @param _value The total value of the given sale.
      * @param _precision The precision with which to manipulate _value, to prevent overflow/underflow.
      * @return 0.5% of _value.
      */
    function calculateDeveloperFee(
        uint _value,
        uint _precision
    ) internal pure returns(uint) {
        if (_precision == 15) {
            return (_value / 1e15) * (5 * 1e12);
        } else if (_precision == 16) {
            return (_value / 1e16) * (5 * 1e13);
        } else if (_precision == 17) {
            return (_value / 1e17) * (5 * 1e14);
        } else {
            return (_value / 1e18) * (5 * 1e15);
        }
    }

    /** @dev Calculates the precision needed to manipulate a given value, to prevent overflow/underflow.
      * @param _value The value to calculate precision for.
      * @return The highest number at which (_value / 1e<number>) will not overflow/underflow.
      */
    function calculatePrecision(
        uint _value
    ) internal pure returns (uint) {
        if (_value >= 1000000000000000000) {
            return 18;
        } else if (_value >= 100000000000000000) {
            return 17;
        } else if (_value >= 10000000000000000) {
            return 16;
        } else if (_value >= 1000000000000000) {
            return 15;
        }
        return 18;
    }

    /** @dev Multiplies the first two values together and divides the product by the third value (assuming 18 or less decimal places).
      * @param _x The first value (factor).
      * @param _y The second value (factor).
      * @param _z The third value (divisor).
      * @return ((_x * _y) / _z).
      */
    function mulDiv (
        uint _x,
        uint _y,
        uint _z
    ) public pure returns (uint) {
        uint a = _x / _z;
        uint b = _x % _z;
        uint c = _y / _z;
        uint d = _y % _z;

        return a * b * _z + a * d + b * c + b * d / _z;
    }

    /** @dev Adds a listing to the marketplace.
      * @param _collection The address of the collection that the listing is from.
      * @param _tokenId The token ID of the listing.
      * @param _price The price to list the token at.
      */
    function addListing(
        address _collection,
        uint _tokenId,
        uint _price
    ) public payable nonReentrant {
        require(msg.sender == IERC721(_collection).ownerOf(_tokenId), "You do not own the item that you are trying to list.");
        require(_price >= 1000000000000000, "Listings must be at least 0.001 ETH.");
        require(msg.value == 0, "Do not attach extra ether to this transaction.");

        _listings.increment();
        uint listingKey = _listings.current();

        uint precision = calculatePrecision(_price);

        uint date = block.number;
    
        listing[listingKey] = Listing(
            listingKey,
            _collection,
            _tokenId,
            payable(msg.sender),
            payable(address(0)),
            _price,
            precision,
            false,
            false,
            date
        );

        IERC721(_collection).transferFrom(msg.sender, address(this), _tokenId);

        emit ListingAdded(
            listingKey,
            _collection,
            _tokenId,
            msg.sender,
            address(0),
            _price,
            precision,
            false,
            false,
            date
        );
    }

    /** @dev Removes a listing from the marketplace.
      * @param _listingKey The key of the listing to be removed.
      */
    function removeListing (
        uint _listingKey
    ) public payable nonReentrant {
        require(msg.sender == listing[_listingKey].seller, "This listing is not under your custody.");
        require(listing[_listingKey].cancelled == false, "This listing has been cancelled.");

        listing[_listingKey].cancelled = true;

        emit ListingRemoved(
            _listingKey,
            listing[_listingKey].collection,
            listing[_listingKey].tokenId,
            msg.sender,
            msg.sender,
            listing[_listingKey].price,
            listing[_listingKey].precision,
            false,
            true,
            block.number
        );
    }

    /** @dev Purchases a listing from the marketplace.
      * @param _collection The address of the collection that the listing is from.
      * @param _listingKey The key of the listing to be purchased.
      */
    function purchaseListing(
        address _collection,
        uint _listingKey
    ) public payable nonReentrant {
        uint price = listing[_listingKey].price;
        uint precision = listing[_listingKey].precision;
        uint feeStaker = calculateStakerFee(price, precision);
        uint feeDeveloper = calculateDeveloperFee(price, precision);
        uint fees = feeStaker + feeDeveloper;
        uint tokenId = listing[_listingKey].tokenId;
        require(listing[_listingKey].cancelled == false, "This listing has been cancelled.");
        require(listing[_listingKey].sold == false, "This listing has already been sold.");
        require(listing[_listingKey].collection == _collection, "This listing is part of a different collection.");
        require(listing[_listingKey].tokenId == tokenId, "This listing is of a different token ID.");
        require(msg.value == price + fees, "Ensure the value of this transaction is 102.5% of the listing price.");

        listing[_listingKey].seller.transfer(price);
        IERC721(_collection).transferFrom(address(this), msg.sender, tokenId);
        listing[_listingKey].owner = payable(msg.sender);
        listing[_listingKey].sold = true;
        _sales.increment();
        collectionVolume[_collection] += price;
        totalVolume += price;
        totalFees += fees;

        uint totalAmount = tokens;

        if (totalAmount > 0) {
            for (uint i = 0; i < stakers.length; i++) {
                address staker = stakers[i];

                unclaimedRewards[staker] += mulDiv(feeStaker, stake[staker], totalAmount);
            }

            rewardsUnclaimed += feeStaker;
            rewardsAll += feeStaker;
        }

        payable(developerWallet).transfer(feeDeveloper);
    }

    /** @dev Adds an offer to the marketplace.
      * @param _collection The address of the collection that the item is from.
      * @param _tokenId The token ID of the item.
      * @param _price The value of the offer.
      */
    function addOffer(
        address _collection,
        uint _tokenId,
        uint _price
    ) public payable nonReentrant {
        require(_price >= 1000000000000000, "Offers must be at least 0.001 ETH.");
        require(msg.value == _price, "The value of this transaction must match the amount offered.");

        _offers.increment();
        uint offerKey = _offers.current();

        uint precision = calculatePrecision(_price);

        uint date = block.number;
    
        offer[offerKey] = Offer(
            offerKey,
            _collection,
            _tokenId,
            payable(msg.sender),
            _price,
            precision,
            false,
            false,
            date
        );

        emit OfferAdded(
            offerKey,
            _collection,
            _tokenId,
            msg.sender,
            _price,
            precision,
            false,
            false,
            date
        );
    }

    /** @dev Removes an offer from the marketplace.
      * @param _offerKey The key of the offer to be removed.
      */
    function removeOffer(
        uint _offerKey
    ) public payable nonReentrant {
        require(offer[_offerKey].cancelled == false, "This offer has been cancelled.");
        require(offer[_offerKey].sold == false, "This offer has been accepted.");
        require(msg.sender == offer[_offerKey].bidder, "This offer is not under your custody.");

        offer[_offerKey].cancelled = true;

        payable(msg.sender).transfer(offer[_offerKey].price);

        emit OfferRemoved(
            _offerKey,
            offer[_offerKey].collection,
            offer[_offerKey].tokenId,
            msg.sender,
            offer[_offerKey].price,
            offer[_offerKey].precision,
            false,
            true,
            block.number
        );
    }

    /** @dev Accepts an offer for an item.
      * @param _collection The address of the collection that the item is from.
      * @param _offerKey The key of the offer to be accepted.
      */
    function acceptOffer(
        address _collection,
        uint _offerKey
    ) public payable nonReentrant {
        uint price = offer[_offerKey].price;
        uint precision = offer[_offerKey].precision;
        uint feeStaker = calculateStakerFee(price, precision);
        uint feeDeveloper = calculateDeveloperFee(price, precision);
        uint fees = feeStaker + feeDeveloper;
        uint tokenId = offer[_offerKey].tokenId;
        require(offer[_offerKey].cancelled == false, "This offer has been cancelled.");
        require(offer[_offerKey].sold == false, "This offer has already been accepted.");
        require(offer[_offerKey].collection == _collection, "This offer is part of a different collection.");
        require(offer[_offerKey].tokenId == tokenId, "This offer is of a different token ID.");
        require(msg.sender == IERC721(offer[_offerKey].collection).ownerOf(tokenId), "You do not own the item that this offer is valid for.");

        payable(msg.sender).transfer(offer[_offerKey].price - fees);
        IERC721(_collection).transferFrom(msg.sender, offer[_offerKey].bidder, tokenId);
        offer[_offerKey].sold = true;
        collectionVolume[_collection] += price;
        totalVolume += price;
        totalFees += fees;

        uint totalAmount = tokens;

        if (totalAmount > 0) {
            for (uint i = 0; i < stakers.length; i++) {
                address staker = stakers[i];

                unclaimedRewards[staker] += mulDiv(feeStaker, stake[staker], totalAmount);
            }

            rewardsUnclaimed += feeStaker;
            rewardsAll += feeStaker;
        }

        payable(developerWallet).transfer(feeDeveloper);
    }

    /** @dev Retrieves the listings of a given item.
      * @param _collection The address of the collection that the item is from.
      * @param _tokenId The token ID of the item.
      * @return The array of listings that match the query.
      */
    function retrieveListingsByItem(
        address _collection,
        uint _tokenId
    ) public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].collection == _collection && listing[i + 1].tokenId == _tokenId) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].collection == _collection && listing[i + 1].tokenId == _tokenId) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the listings in a given collection.
      * @param _collection The address of the collection.
      * @return The array of listings that match the query.
      */
    function retrieveListingsByCollection(
        address _collection
    ) public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].collection == _collection) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].collection == _collection) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the listings from a given account.
      * @param _account The address of the account to retrieve listings from.
      * @return The array of listings that match the query.
      */
    function retrieveListingsByAccount(
        address _account
    ) public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].seller == _account) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].seller == _account) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the listings after a given block height.
      * @param _fromBlock The earliest block to retrieve listings from.
      * @return The array of listings that match the query.
      */
    function retrieveListingsFromBlock(
        uint _fromBlock
    ) public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].date >= _fromBlock) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].date >= _fromBlock) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's active listings.
      * @return The array of all listings that have not been sold or cancelled.
      */
    function retrieveListingsActive() public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].sold == false && listing[i + 1].cancelled == false) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].sold == false && listing[i + 1].cancelled == false) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's sold listings.
      * @return The array of all listings that have been sold.
      */
    function retrieveListingsSold() public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].sold == true) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].sold == true) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's cancelled listings.
      * @return The array of all listings that have been cancelled.
      */
    function retrieveListingsCancelled() public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].cancelled == true) {
                matches += 1;
            }
        }

        Listing[] memory items = new Listing[](matches);
        for (uint i = 0; i < numListings; i++) {
            if (listing[i + 1].cancelled == true) {
                Listing storage currentItem = listing[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's listings.
      * @return The array of all listings.
      */
    function retrieveListingsAll() public view returns (Listing[] memory) {
        uint numListings = _listings.current();
        uint cursor = 0;

        Listing[] memory items = new Listing[](numListings);
        for (uint i = 0; i < numListings; i++) {
            Listing storage currentItem = listing[i + 1];
            items[cursor] = currentItem;
            cursor += 1;
        }
        return items;
    }

    /** @dev Retrieves the offers for a given item.
      * @param _collection The address of the collection that the item is from.
      * @param _tokenId The token ID of the item.
      * @return The array of offers that match the query.
      */
    function retrieveOffersByItem(
        address _collection,
        uint _tokenId
    ) public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].collection == _collection && offer[i + 1].tokenId == _tokenId) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].collection == _collection && offer[i + 1].tokenId == _tokenId) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the offers in a given collection.
      * @param _collection The address of the collection.
      * @return The array of offers that match the query.
      */
    function retrieveOffersByCollection(
        address _collection
    ) public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].collection == _collection) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].collection == _collection) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the offers from a given account.
      * @param _account The address of the account to retrieve offers from.
      * @return The array of offers that match the query.
      */
    function retrieveOffersByAccount(
        address _account
    ) public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].bidder == _account) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].bidder == _account) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves the offers after a given block height.
      * @param _fromBlock The earliest block to retrieve offers from.
      * @return The array of offers that match the query.
      */
    function retrieveOffersFromBlock(
        uint _fromBlock
    ) public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].date >= _fromBlock) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].date >= _fromBlock) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's active offers.
      * @return The array of all offers that have not been accepted or cancelled.
      */
    function retrieveOffersActive() public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].sold == false && offer[i + 1].cancelled == false) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].sold == false && offer[i + 1].cancelled == false) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's accepted offers.
      * @return The array of all offers that have been accepted.
      */
    function retrieveOffersSold() public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].sold == true) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].sold == true) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's cancelled offers.
      * @return The array of all offers that have been cancelled.
      */
    function retrieveOffersCancelled() public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint matches = 0;
        uint cursor = 0;

        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].cancelled == true) {
                matches += 1;
            }
        }

        Offer[] memory items = new Offer[](matches);
        for (uint i = 0; i < numOffers; i++) {
            if (offer[i + 1].cancelled == true) {
                Offer storage currentItem = offer[i + 1];
                items[cursor] = currentItem;
                cursor += 1;
            }
        }
        return items;
    }

    /** @dev Retrieves all of the marketplace's offers.
      * @return The array of all offers.
      */
    function retrieveOffersAll() public view returns (Offer[] memory) {
        uint numOffers = _offers.current();
        uint cursor = 0;

        Offer[] memory items = new Offer[](numOffers);
        for (uint i = 0; i < numOffers; i++) {
            Offer storage currentItem = offer[i + 1];
            items[cursor] = currentItem;
            cursor += 1;
        }
        return items;
    }

    /** @dev Retrieves the deployer address.
      * @return The address of the contract deployer.
      */
    function getDeployerAddress() public view returns (address payable) {
        return deployerAddress;
    }

    /** @dev Retrieves the developer wallet.
      * @return The address of the contract developer.
      */
    function getDeveloperWallet() public view returns (address payable) {
        return developerWallet;
    }

    /** @dev Retrieves the total volume of a given collection.
      * @param _collection The address of the collection.
      * @return The cumulative lifetime value of purchased listings and accepted offers within _collection, denominated in Wei.
      */
    function getVolumeByCollection(
        address _collection
    ) public view returns (uint) {
        return collectionVolume[_collection];
    }

    /** @dev Retrieves the total volume.
      * @return The cumulative lifetime value of purchased listings and accepted offers, denominated in Wei.
      */
    function getVolumeTotal() public view returns (uint) {
        return totalVolume;
    }

    /** @dev Retrieves the total fees.
      * @return The cumulative lifetime fees accrued, denominated in Wei.
      */
    function getFeesTotal() public view returns (uint) {
        return totalFees;
    }

    /** @dev Adds a stake.
      * @param _amount The amount of BUCK tokens to stake.
      */
    function addStake(
        uint _amount
    ) public nonReentrant {
        require(_amount >= 1000 * 1e18, "You must stake at least 1,000 BUCK tokens.");
        require(buckToken.balanceOf(msg.sender) >= _amount, "Your stake cannot be greater than your balance.");

        buckToken.transferFrom(msg.sender, address(this), _amount);
        stake[msg.sender] = stake[msg.sender] + _amount;

        if (!isStaker[msg.sender]) {
            stakers.push(msg.sender);
            isStaker[msg.sender] = true;
        }

        if (!isStaking[msg.sender]) {
            isStaking[msg.sender] = true;
        }

        tokens += _amount;
    }

    /** @dev Removes a stake.
      * @param _amount The amount of BUCK tokens to unstake.
      */
    function removeStake(
        uint _amount
    ) public nonReentrant {
        uint balance = stake[msg.sender];
        require(balance > 0, "You must own a stake of at least one token to do this.");
        require(balance >= _amount, "You cannot claim more tokens than the balance of your stake.");

        stake[msg.sender] = balance - _amount;
        buckToken.transfer(msg.sender, _amount);

        if (balance - _amount == 0) {
            isStaking[msg.sender] = false;
        }

        tokens -= _amount;
    }

    /** @dev Claims staking rewards. */
    function claimRewards() public payable nonReentrant {
        require(isStaker[msg.sender] == true, "You must currently own or have previously owned a stake to do this.");

        uint rewards = unclaimedRewards[msg.sender];

        payable(msg.sender).transfer(rewards);
        unclaimedRewards[msg.sender] = 0;
        claimedRewards[msg.sender] += rewards;

        rewardsUnclaimed -= rewards;
    }

    /** @dev Retrieves the total BUCK tokens staked.
      * @return The number of currently staked BUCK tokens.
      */
    function getStakeTotal() public view returns (uint) {
        return tokens;
    }

    /** @dev Retrieves the total rewards generated by staking.
      * @return The rewards generated by staking, denominated in Wei.
      */
    function getRewardsTotal() public view returns (uint) {
        return rewardsAll;
    }

    /** @dev Retrieves the total unclaimed rewards generated by staking.
      * @return The unclaimed rewards generated by staking, denominated in Wei.
      */
    function getUnclaimedRewardsTotal() public view returns (uint) {
        return rewardsUnclaimed;
    }

    /** @dev Retrieves the stake of a given user.
      * @param _user The address to check the stake of.
      * @return The amount of BUCK tokens that _user currently has staked.
      */
    function getStakeByUser(
        address _user
    ) public view returns (uint) {
        return stake[_user];
    }

    /** @dev Retrieves the unclaimed rewards of a given user.
      * @param _user The address to check the unclaimed rewards of.
      * @return The amount of unclaimed rewards that _user is entitled to, denominated in Wei.
      */
    function getUnclaimedRewardsByUser(
        address _user
    ) public view returns (uint) {
        return unclaimedRewards[_user];
    }

    /** @dev Retrieves the claimed rewards offers a given user.
      * @param _user The address to check the claimed rewards of.
      * @return The amount of rewards that _user has already claimed, denominated in Wei.
      */
    function getClaimedRewardsByUser(
        address _user
    ) public view returns (uint) {
        return claimedRewards[_user];
    }

    /** @dev Retrieves the canonical BUCK token address.
      * @return The address of the BUCK token that this marketplace was constructed with.
      */
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }
}