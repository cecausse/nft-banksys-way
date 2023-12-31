// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BanksysWayDutchAuction.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @author Modified version of original code by 1001.digital
/// Change totalSupply to maxSupply to avoid compatibility problem with ERC721Enumerable
/// @title A token tracker that limits the token supply and increments token IDs on each new mint.
abstract contract WithLimitedSupply is BanksysWayDutchAuction {
    using Counters for Counters.Counter;

    // Keeps track of how many we have minted
    Counters.Counter private _tokenCount;

    /// @dev The maximum count of tokens this token tracker will hold.
    uint256 private _maxSupply;

    /// Instanciate the contract
    /// @param maxSupply_ how many tokens this collection should hold
    constructor(uint256 maxSupply_) {
        _maxSupply = maxSupply_;
    }

    /// @dev Get the max Supply
    /// @return the maximum token count
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /// @dev Get the current token count
    /// @return the created token count
    function tokenCount() public view returns (uint256) {
        return _tokenCount.current();
    }

    /// @dev Check whether tokens are still available
    /// @return the available token count
    function availableTokenCount() public view returns (uint256) {
        return maxSupply() - tokenCount();
    }

    /// @dev Increment the token count and fetch the latest count
    /// @return the next token id
    function nextToken() internal virtual returns (uint256) {
        uint256 token = _tokenCount.current();

        _tokenCount.increment();

        return token;
    }

    /// @dev Check whether another token is still available
    modifier ensureAvailability() {
        require(availableTokenCount() > 0, "No more tokens available");
        _;
    }

    /// @param amount Check whether number of tokens are still available
    /// @dev Check whether tokens are still available
    modifier ensureAvailabilityFor(uint256 amount) {
        require(
            availableTokenCount() >= amount,
            "Requested number of tokens not available"
        );
        _;
    }
}
