// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RepairToolRandomVariable is Ownable {
    mapping(uint256 => uint256) internal _toolValue;
    mapping(uint256 => uint256) internal _toolCharge;
    mapping(uint256 => uint256) internal _toolBlock;

    /**
     * @dev We factor the variables into a single uint256
     * In order, X representing the number of dedicated slots in the uint variable
     * X magicTapeToolCharge;
     * X timeMachineToolCharge = 1;
     * X glueToolCharge = 3;
     * X staplerToolCharge = 3;
     * XXX magicTapeToolChance = 10;
     * XXX timeMachineToolChance = 60;
     * XXX glueToolChance = 230;
     * XXXX totalChance (staplerTool = total - others) = 1000;
     * XX magicTapeToolWaiting (days);
     * XX glueToolWaiting = 15 days;
     * XX staplerToolWaiting = 30 days;
     * XXXXX baseWaiting = 86400
     */

    uint256 public toolProperty = 2133010060230100005153086400;

    /**
     * @dev To change the tools properties
     */
    function setToolProperty(uint256 _val) external onlyOwner {
        toolProperty = _val;
    }

    /**
     * @return The toolProperty
     */
    function getRepairToolRandomVariable() public view returns (uint256) {
        return toolProperty;
    }

    /**
     * @dev Internal function to extract the desired value in toolProperties
     */
    function _getGlobalToolProperty(uint256 _div, uint256 _rest)
        internal
        view
        returns (uint256)
    {
        uint256 b = toolProperty / _div;
        if (_rest == 0) {
            return b;
        }
        uint256 c = b % _rest;
        return c;
    }
}
