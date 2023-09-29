// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RepairToolContractsInterfaces.sol";

abstract contract RepairToolRandom is RepairToolContractsInterfaces {
    /**
     * @dev Internal function to define which tool the minter get
     */
    function _setRandomValueToTool(uint256 _toolId, uint256 _randomNumber)
        internal
    {
        // Magic Tape
        if (
            _randomNumber <=
            _getGlobalToolProperty(1000000000000000000000, 1000)
        ) {
            _toolValue[_toolId] = 1;
            _toolCharge[_toolId] = _getGlobalToolProperty(
                1000000000000000000000000000,
                10
            );
            emit ToolValue(1);
        }
        // Time Machine
        else if (
            _randomNumber <= _getGlobalToolProperty(1000000000000000000, 1000)
        ) {
            _toolValue[_toolId] = 2;
            _toolCharge[_toolId] = _getGlobalToolProperty(
                100000000000000000000000000,
                10
            );
            emit ToolValue(2);
        }
        // Glue
        else if (
            _randomNumber <= _getGlobalToolProperty(1000000000000000, 1000)
        ) {
            _toolValue[_toolId] = 3;
            _toolCharge[_toolId] = _getGlobalToolProperty(
                10000000000000000000000000,
                10
            );
            emit ToolValue(3);
        }
        // Stapler
        else {
            _toolValue[_toolId] = 4;
            _toolCharge[_toolId] = _getGlobalToolProperty(
                1000000000000000000000000,
                10
            );
            emit ToolValue(4);
        }
    }

    function _getRandomValue(uint256 _toolId) internal {
        uint256 total = _getGlobalToolProperty(100000000000, 10000);
        uint256 seed = rn.getRandomNumber(msg.sender) + _toolId;
        _setRandomValueToTool(_toolId, (seed % total) + 1);
    }
}
