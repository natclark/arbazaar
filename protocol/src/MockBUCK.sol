// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/** @title Mock BUCK. */
contract MockBUCK is ERC20 {
    /** @dev Creates 100M mock BUCK tokens for testing purposes.
      * @param _deployer The address to send the minted tokens to.
      */
    constructor(
        address _deployer
    ) ERC20("Arbucks", "BUCK") {
        _mint(_deployer, 100000000000000000000000000);
    }
}