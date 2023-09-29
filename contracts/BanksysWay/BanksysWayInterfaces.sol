// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWayERC721Base.sol";

interface IRepairTool {
    function ownerOf(uint256 _toolId) external view returns (address);

    function useToolsFromBanksysWay(uint256 _toolId) external;

    function successRepair(uint256 _toolId) external;

    function getToolProperty(uint256 _toolId)
        external
        view
        returns (
            uint256,
            bool,
            uint256,
            uint256,
            uint256
        );
}

interface IRandomNumber {
    function getRandomNumber(address _address) external view returns (uint256);
}

interface ICalculLogic {
    function calculChanceToFix(uint256 _levelDestroy, uint256 _properties)
        external
        pure
        returns (uint256[] memory);

    function calculateChanceToAllow(
        uint256 _indexLevel,
        uint256[] memory _countPerLevel,
        uint256 _countAllow,
        uint256 _allowProperties
    ) external pure returns (uint256);

    function getProperties(
        uint256 _div,
        uint256 _rest,
        uint256 _properties
    ) external pure returns (uint256);

    function calculBlockAllow(uint256 _destroyLevel, uint256 _allowProperties)
        external
        view
        returns (uint256);
}

abstract contract BanksysWayInterfaces is BanksysWayERC721Base {
    IRepairTool internal iRt;
    IRandomNumber internal iRn;
    ICalculLogic internal iCl;

    /**
     * @dev Set the address of RandomNumber Contract
     */
    function setRandomNumber(address _address) public onlyOwner {
        iRn = IRandomNumber(_address);
    }

    /**
     * @dev Set the address of CalculLogic Contract
     */
    function setCalculLogic(address _address) public onlyOwner {
        iCl = ICalculLogic(_address);
    }
}
