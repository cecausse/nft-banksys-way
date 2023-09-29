// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWayInterfaces.sol";

abstract contract BanksysWayFix is BanksysWayInterfaces {
    /** @dev We factor the variables into a single uint256
     * In order, X representing the number of dedicated slots in the uint variable
     * XXXX chanceToSuccess = 1000;
     * XXX magicTapeSuccessChance = 910;
     * XXX magicTapeFailedChance = 990;
     * XXX timeMachineSuccessChance = 450;
     * XXX glueSuccessChance = 190;
     * XXX glueFailedChance = 990;
     * XXX staplerSuccessChance = 110;
     * XXX staplerFailedChance = 980;
     * XX levelMagicTape = 10;
     * XX levelTimeMachine = 10;
     * XX levelGlue = 10;
     * XX levelStapler = 10;
     */

    uint256 public fixProperties = 100091099045019099011098010201010;

    /**
     * @dev To change the fix properties
     */
    function setFixProperties(uint256 _val) external onlyOwner {
        fixProperties = _val;
    }

    /**
     * @notice Call this function to try to get the ultimate form.
     * You need :
     *   - An NFT not already in the ultimate form
     *   - A tool that can be used
     * WARNING : when you call this function,
     * there is a risk that your NFTs will be permanently destroyed.
     * For more information, read the documentation at docs.banksysway.com
     */
    function tryUltimatePiece(uint256 _tokenId, uint256 _toolId) external {
        require(
            ownerOf(_tokenId) == msg.sender,
            "You need to have the genesis part"
        );
        require(_destroyLevel[_tokenId] > 0, "Already in the last shape");
        require(iRt.ownerOf(_toolId) == msg.sender, "You don't own this tool");
        (, bool canBeUsed, , , ) = iRt.getToolProperty(_toolId);
        require(canBeUsed, "Tool is not ready yet");
        emit UltimatePieceTry(_tokenId, _toolId);
        uint256 seed = iRn.getRandomNumber(msg.sender);
        bigBang(
            _tokenId,
            _toolId,
            msg.sender,
            ((seed) %
                iCl.getProperties(
                    100000000000000000000000000000,
                    10000,
                    fixProperties
                )) + 1
        );
    }

    /**
     * @notice BIGBANG !!!!!!!!!!!!!!!!
     */
    function bigBang(
        uint256 _tokenId,
        uint256 _toolId,
        address _address,
        uint256 _randomNumber
    ) internal {
        (uint256 _toolValue, , , , ) = iRt.getToolProperty(_toolId);
        uint256[] memory chanceFix = iCl.calculChanceToFix(
            _destroyLevel[_tokenId],
            fixProperties
        );
        if (_toolValue == 1) {
            if (_randomNumber <= chanceFix[0]) {
                iRt.successRepair(_toolId);
                success(_tokenId, _address);
            } else if (_randomNumber <= chanceFix[1]) {
                iRt.useToolsFromBanksysWay(_toolId);
                emit UltimatePieceFailed(_tokenId, _address);
            } else {
                iRt.useToolsFromBanksysWay(_toolId);
                _burn(_tokenId);
                emit UltimatePieceBurned(_tokenId, _address);
            }
        } else if (_toolValue == 2) {
            if (_randomNumber <= chanceFix[2]) {
                iRt.successRepair(_toolId);
                success(_tokenId, _address);
            } else {
                iRt.useToolsFromBanksysWay(_toolId);
                _burn(_tokenId);
                emit UltimatePieceBurned(_tokenId, _address);
            }
        } else if (_toolValue == 3) {
            if (_randomNumber <= chanceFix[3]) {
                iRt.successRepair(_toolId);
                success(_tokenId, _address);
            } else if (_randomNumber <= chanceFix[4]) {
                iRt.useToolsFromBanksysWay(_toolId);
                emit UltimatePieceFailed(_tokenId, _address);
            } else {
                iRt.useToolsFromBanksysWay(_toolId);
                _burn(_tokenId);
                emit UltimatePieceBurned(_tokenId, _address);
            }
        } else {
            if (_randomNumber <= chanceFix[5]) {
                iRt.successRepair(_toolId);
                success(_tokenId, _address);
            } else if (_randomNumber <= chanceFix[6]) {
                iRt.useToolsFromBanksysWay(_toolId);
                emit UltimatePieceFailed(_tokenId, _address);
            } else {
                iRt.useToolsFromBanksysWay(_toolId);
                _burn(_tokenId);
                emit UltimatePieceBurned(_tokenId, _address);
            }
        }
    }

    /**
     * @notice If this function is called by the contract, you will be very happy
     */
    function success(uint256 _tokenId, address _address) internal {
        _destroyLevel[_tokenId] = 0;
        emit UltimatePiece(_tokenId, _address);
    }
}
