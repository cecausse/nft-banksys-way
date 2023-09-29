// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BanksysWayERC721Base is Ownable, ERC721Enumerable {
    using Strings for uint256;

    string internal baseURI;
    string internal notRevealedURI;
    bool internal revealed = false;

    bytes32 internal hashBaseUri;

    mapping(uint256 => uint256) internal _destroyLevel;
    mapping(uint256 => uint256) internal _countPerLevel;

    event BanksysWayAllow(uint256 _tokenId);
    event BanksysWayFailedAllow(uint256 _tokenId);
    event UltimatePiece(uint256 _tokenId, address _address);
    event UltimatePieceFailed(uint256 _tokenId, address _address);
    event UltimatePieceBurned(uint256 _tokenId, address _address);
    event UltimatePieceTry(uint256 _tokenId, uint256 _toolId);

    /**
     * @return Number of NFT in each level of destruction
     */
    function getCountPerLevel(uint256 _index) public view returns (uint256) {
        return _countPerLevel[_index];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _indexURI(uint256 _index)
        internal
        view
        virtual
        returns (string memory)
    {
        return string(abi.encodePacked(_index.toString(), "/"));
    }

    /**
     * @dev We check that the URI has not modified since the creation of the contract.
     * This is a security to prevent developers change the URI after the sale.
     */
    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        require(
            keccak256(abi.encodePacked(_newBaseURI)) == hashBaseUri,
            "This is not the right URI"
        );
        baseURI = _newBaseURI;
    }
}
