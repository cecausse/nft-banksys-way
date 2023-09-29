// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RepairToolRandom.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RepairTool is RepairToolRandom {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using Strings for uint256;

    constructor(string memory _baseUri, address _randomNumberAddress)
        ERC721("Repair tool for Banksy's way", "RTBW")
    {
        setBaseURI(_baseUri);
        setRandomNumber(_randomNumberAddress);
    }

    /**
     * @notice Tool mint function, caller need to own a NFT allow to mint
     */
    function mint(uint256 _tokenId) external {
        (bool allow, bool ownerOf) = bw.getAllowToMint(_tokenId, msg.sender);
        require(allow && ownerOf, "Not allow or not owner");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _getRandomValue(newItemId);
        bw.setAllowToMintFalse(_tokenId);
    }

    /**
     * @return Uri of the specified tool
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _toolValue[tokenId].toString()
                    )
                )
                : "";
    }
}
