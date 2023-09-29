// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RepairToolERC721Base.sol";

interface IRandomNumber {
    function getRandomNumber(address _address) external view returns (uint256);
}

interface IBanksysWay {
    function getAllowToMint(uint256 _tokenId, address _address)
        external
        view
        returns (bool, bool);

    function setAllowToMintFalse(uint256 _tokenId) external;
}

abstract contract RepairToolContractsInterfaces is RepairToolERC721Base {
    IBanksysWay internal bw;
    IRandomNumber internal rn;

    modifier onlyBanksysWayContract() {
        require(msg.sender == address(bw), "Only BanksysWayContract");
        _;
    }

    /**
     * @dev Call by main contract to consume one charge (the tool burn if it was the last charge)
     */
    function useToolsFromBanksysWay(uint256 _toolId)
        public
        onlyBanksysWayContract
    {
        uint256 value = _toolValue[_toolId];
        // If there was only one charge left
        if (_toolCharge[_toolId] <= 1) {
            // The tool is burned
            _burn(_toolId);
        }
        // Otherwise:
        //   - we reduce the charge by 1
        //   - we block the use of the tool for a given period (depending on the tool)
        else {
            _toolCharge[_toolId] = _toolCharge[_toolId] - 1;
            if (value == 1) {
                _toolBlock[_toolId] =
                    block.timestamp +
                    _getGlobalToolProperty(1000000000, 100) *
                    _getGlobalToolProperty(1, 100000);
            } else if (value == 3) {
                _toolBlock[_toolId] =
                    block.timestamp +
                    _getGlobalToolProperty(10000000, 100) *
                    _getGlobalToolProperty(1, 100000);
            } else if (value == 4) {
                _toolBlock[_toolId] =
                    block.timestamp +
                    _getGlobalToolProperty(100000, 100) *
                    _getGlobalToolProperty(1, 100000);
            }
        }
    }

    /**
     * @return Get all the property of the _toolId
     *   - value of tool (magic tape, glue etc...)
     *   - boolean which defines if it can be used
     *   - the time remaining before it can be used again (0 if canBeUsed == true)
     *   - charge's remaining
     *   - timestamp when it can be used again
     */
    function getToolProperty(uint256 _toolId)
        public
        view
        returns (
            uint256,
            bool,
            uint256,
            uint256,
            uint256
        )
    {
        bool canBeUsed;
        uint256 timeLeft;
        if (block.timestamp > _toolBlock[_toolId]) {
            canBeUsed = true;
        } else {
            canBeUsed = false;
            timeLeft = _toolBlock[_toolId] - block.timestamp;
        }
        return (
            _toolValue[_toolId],
            canBeUsed,
            timeLeft,
            _toolCharge[_toolId],
            _toolBlock[_toolId]
        );
    }

    /**
     * @dev Call by main contract when the tool succesfully repair a NFT, the tool is destroy
     */
    function successRepair(uint256 _toolId) public onlyBanksysWayContract {
        _burn(_toolId);
    }

    /**
     * @dev Set the address of Banksy's way contract, can be called only once
     */
    function setBanksysWay(address _address) public onlyOwner {
        require(address(bw) == address(0), "Already set");
        bw = IBanksysWay(_address);
    }

    /**
     * @dev Set the address of RandomNumber Contract
     */
    function setRandomNumber(address _address) public onlyOwner {
        rn = IRandomNumber(_address);
    }
}
