// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RandomNumberPriceFeed.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract RandomNumber is RandomNumberPriceFeed {
    /**
     * @return Random number
     */
    function getRandomNumber(address _address) external view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(_address)))) /
                            (block.timestamp)) +
                        block.number +
                        ((uint256(keccak256(abi.encodePacked(getAllPrice())))) /
                            (block.timestamp)) +
                        uint256(blockhash(block.number - 1))
                )
            )
        );
        return seed;
    }
}
