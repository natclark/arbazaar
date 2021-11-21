// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
    THIS CONTRACT IS A WORK IN PROGRESS AND IS NOT CURRENTLY IN PRODUCTION.

    IT MAY BE INCLUDED IN ARBAZAAR V2 OR DEPLOYED AS A SEPARATE EXTENSION.
*/

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** @title CollectionProfile. */
contract CollectionProfile is ReentrancyGuard {
    address payable deployerAddress;

    address tokenAddress;
    IERC20 public buckToken;

    /** @dev Creates a verifcation process for collection owners/deployers to update their marketplace profile.
      * @param _buckTokenAddress The canonical BUCK token address.
      */
    constructor(
        address _buckTokenAddress
    ) {
        deployerAddress = payable(msg.sender);
        tokenAddress = _buckTokenAddress;
        buckToken = IERC20(tokenAddress);
    }

    struct Profile {
        string pictureBanner;
        string pictureProfile;
        // TODO
    }

    function updateProfile(
        string memory pictureBanner,
        string memory pictureProfile
        // TODO
    ) public payable nonReentrant {
        // TODO
    }

    /** @dev Retrieves the deployer address.
      * @return The address of the contract deployer.
      */
    function getDeployerAddress() public view returns (address payable) {
        return deployerAddress;
    }

    /** @dev Retrieves the canonical BUCK token address.
      * @return The address of the BUCK token that this marketplace was constructed with.
      */
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }
}