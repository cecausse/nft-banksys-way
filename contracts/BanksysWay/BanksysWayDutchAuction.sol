// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWaySale.sol";

abstract contract BanksysWayDutchAuction is BanksysWaySale {
    uint256 internal startingPrice;
    uint256 internal levelingPrice;
    uint256 internal startAt;
    uint256 internal expiresAt;
    uint256 internal whitelistEnd;

    /**
     * @return Current price and phase number
     */
    function getAuctionData() public view returns (uint256, uint256) {
        if (startAt == 0) {
            return (0, 0);
        } else if (block.timestamp < expiresAt) {
            uint256 levelOfDestroy = (((block.timestamp - startAt) * 8) /
                (expiresAt - startAt));
            uint256 currentPrice = startingPrice *
                1000000000 -
                levelOfDestroy *
                levelingPrice *
                1000000000;
            return (currentPrice, (levelOfDestroy + 1));
        } else {
            return (
                startingPrice * 1000000000 - 8 * levelingPrice * 1000000000,
                9
            );
        }
    }

    function isWhitelistInProgress() public view returns (bool) {
        return block.timestamp < whitelistEnd ? true : false;
    }

    /**
     * @dev Launch the sale
     */
    function startAuction(
        uint256 _startingPrice,
        uint256 _levelingPrice,
        uint256 _duration,
        uint256 _whitelistDuration
    ) external onlyOwner {
        startingPrice = _startingPrice;
        levelingPrice = _levelingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + _duration;
        paused = false;
        whitelistEnd = block.timestamp + _whitelistDuration;
    }
}
