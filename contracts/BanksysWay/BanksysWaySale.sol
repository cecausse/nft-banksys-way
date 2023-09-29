// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWayRandom.sol";

abstract contract BanksysWaySale is BanksysWayRandom {
    bool public paused = true;

    /**
     * @dev Pause mint if active
     */
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }

    /**
     * @dev Balance of contract
     */
    function getBalanceContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Withdraw balance of contract
     */
    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: getBalanceContract()
        }("");
        require(success);
    }
}
