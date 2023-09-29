// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWayFix.sol";

abstract contract BanksysWayRandom is BanksysWayFix {
    bool internal manualAllowEnable;

    uint256 internal failedAllow = 0;
    uint256 internal countAllow = 0;
    uint256 internal firstBlock = 0;
    mapping(uint256 => uint256) internal _accessToolFactory;
    mapping(uint256 => bool) internal _allowToMintTool;

    /** @dev We factor the variables into a single uint256
     * In order, X representing the number of dedicated slots in the uint variable
     * X winNumber = 1;
     * XXX baseChanceToAllow = 25;
     * XX coefValue = 4;
     * XXX addingValue = 10;
     * XX divCountAllow = 4;
     * XX delayaccessToolFactory = 3;
     * XX levelaccessToolFactory = 2;
     * XXXXX baseTime = 86400 sec (1 day)
     */

    uint256 allowProperties = 10250401004030286400;

    /**
     * @dev To change the allow properties
     */
    function setAllowProperties(uint256 _val) external onlyOwner {
        allowProperties = _val;
    }

    /**
     * @notice Try to be allow to mint a tool
     */
    function getToolFromWorkshop(uint256 _tokenId) external {
        require(firstBlock <= block.timestamp, "First block");
        require(manualAllowEnable, "Manual allow");
        require(_exists(_tokenId), "Not exists");
        require(ownerOf(_tokenId) == msg.sender, "Not owner");
        require(_destroyLevel[_tokenId] > 0, "Already repair");
        require(
            _accessToolFactory[_tokenId] <= block.timestamp,
            "You already came"
        );
        _getRandomNumber(msg.sender, _tokenId);
    }

    /**
     * @dev Function call just after the sale to allow 10 owner to mint a tool
     */
    function randomAllowAfterSale() external onlyOwner {
        require(countAllow < 10);
        uint256 seed = iRn.getRandomNumber(msg.sender);
        uint256 randomNumber = ((seed % totalSupply()) / 10) + 1;

        for (uint256 i = 0; i < 10; i++) {
            uint256 winNumber = randomNumber + i * (totalSupply() / 10);
            _allowToMintTool[winNumber] = true;
            countAllow += 1;
            emit BanksysWayAllow(winNumber);
        }
    }

    /**
     * @dev To pause allowing process
     */
    function setManualAllowEnable(bool _bool) external onlyOwner {
        manualAllowEnable = _bool;
    }

    /**
     * @return Level of destroy, time left to enter tool factory and
     * if is allow to mint tool
     */
    function getNftData(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            bool
        )
    {
        uint256 dif;
        if (block.timestamp > _accessToolFactory[_tokenId]) {
            dif = 0;
        } else {
            dif = _accessToolFactory[_tokenId] - block.timestamp;
        }
        return (_destroyLevel[_tokenId], dif, _allowToMintTool[_tokenId]);
    }

    /**
     * @return If _tokenId is allow to mint and _address owner of _tokenId
     */
    function getAllowToMint(uint256 _tokenId, address _address)
        external
        view
        returns (bool, bool)
    {
        if (ownerOf(_tokenId) == _address) {
            return (_allowToMintTool[_tokenId], true);
        } else {
            return (_allowToMintTool[_tokenId], false);
        }
    }

    function _getRandomNumber(address _address, uint256 _tokenId) internal {
        uint256 seed = iRn.getRandomNumber(_address);
        uint256[] memory countPerLevelArray = new uint256[](9);
        for (uint256 i = 0; i < 9; i++) {
            countPerLevelArray[i] = _countPerLevel[i];
        }
        _randomAllow(
            ((seed + _tokenId) %
                iCl.calculateChanceToAllow(
                    _destroyLevel[_tokenId],
                    countPerLevelArray,
                    countAllow,
                    allowProperties
                )) + 1,
            _tokenId
        );
    }

    /**
     * @dev Internal function to determine if the owner will be
     * allowed to mint a tool. Then blocks the access to the function
     * getToolFromWorkshop() for a definite time
     */
    function _randomAllow(uint256 _randomNumber, uint256 _tokenId) internal {
        if (
            _randomNumber ==
            iCl.getProperties(10000000000000000000, 10, allowProperties)
        ) {
            _allowToMintTool[_tokenId] = true;
            emit BanksysWayAllow(_tokenId);
            countAllow += 1;
            _accessToolFactory[_tokenId] = iCl.calculBlockAllow(
                _destroyLevel[_tokenId],
                allowProperties
            );
        } else {
            emit BanksysWayFailedAllow(_tokenId);
            _accessToolFactory[_tokenId] = iCl.calculBlockAllow(
                _destroyLevel[_tokenId],
                allowProperties
            );
        }
    }

    modifier onlyRepairToolContract() {
        require(msg.sender == address(iRt));
        _;
    }

    /**
     * @dev Call by RepairTool contract when a user mint a tool
     */
    function setAllowToMintFalse(uint256 _tokenId)
        external
        onlyRepairToolContract
    {
        _allowToMintTool[_tokenId] = false;
    }
}
