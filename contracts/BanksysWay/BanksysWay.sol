// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./BanksysWayWhitelist.sol";

contract BanksysWay is BanksysWayWhitelist {
    using Strings for uint256;

    constructor(
        string memory _notRevealedURI,
        bytes32 _hashBaseUri,
        uint256 _maxSupply,
        address _repairToolContract,
        address _randomNumberContract,
        address _calculLogicContract
    ) ERC721("Banksy's way", "BKSYW") RandomlyAssigned(_maxSupply, 1) {
        notRevealedURI = _notRevealedURI;
        hashBaseUri = _hashBaseUri;
        iRt = IRepairTool(_repairToolContract);
        setRandomNumber(_randomNumberContract);
        setCalculLogic(_calculLogicContract);
    }

    /**
     * @notice Public mint function
     */
    function dutchMint(uint256 _mintAmount)
        external
        payable
        ensureAvailability
        ensureAvailabilityFor(_mintAmount)
    {
        require(startAt != 0, "Sell has not begin yet");
        require(!isWhitelistInProgress(), "Whitelist in progress");
        require(!paused, "Paused");
        require(_mintAmount > 0);
        require(_mintAmount <= 5, "5 is the maximum");
        (uint256 currentPrice, uint256 levelOfDestroy) = getAuctionData();
        require(msg.value >= currentPrice * _mintAmount, "ETH < price");

        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenId = nextToken();
            _safeMint(msg.sender, newTokenId);
            _destroyLevel[newTokenId] = levelOfDestroy;
            _countPerLevel[levelOfDestroy] += 1;
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");

        if (revealed == false) {
            return notRevealedURI;
        }
        string memory currentDestroyURI = _indexURI(_destroyLevel[tokenId]);
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        currentDestroyURI,
                        tokenId.toString()
                    )
                )
                : "";
    }

    /**
     * @dev - Start the logic of destruction
     *      - Reveal the NFT
     *      - Definitively stop minting possibilities (to avoid mint after burn)
     *      - Block access to tool factory for 7 days
     */
    function revealAndStartAllowProcess() external onlyOwner {
        manualAllowEnable = true;
        revealed = true;
        firstBlock =
            block.timestamp +
            2 *
            iCl.getProperties(1, 100000, allowProperties);
    }
}
