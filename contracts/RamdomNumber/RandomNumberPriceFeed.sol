// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

abstract contract RandomNumberPriceFeed is Ownable {
    mapping(uint256 => AggregatorV3Interface) internal priceFeed;
    uint256 internal countOfPriceFeed;

    /**
     * @dev Add pair to priceFeed.
     */
    function setPriceFeed(uint256 _val, address _address) public onlyOwner {
        priceFeed[_val] = AggregatorV3Interface(_address);
    }

    /**
     * @dev Update count of priceFeed
     */
    function setCountOfPriceFeed(uint256 _val) public onlyOwner {
        countOfPriceFeed = _val;
    }

    /**
     * @dev The price may not move over several blocks, but by multiplying the pairs, we limit this risk
     * @return Latest price
     */
    function getLatestPrice(uint256 _index) internal view returns (int256) {
        (, int256 price, , , ) = priceFeed[_index].latestRoundData();
        return price;
    }

    /**
     * @return Sum of all price
     */
    function getAllPrice() internal view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < countOfPriceFeed; i++) {
            total += uint256(getLatestPrice(i));
        }
        return total;
    }
}
