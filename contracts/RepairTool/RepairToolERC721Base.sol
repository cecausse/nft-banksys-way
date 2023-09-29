// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RepairToolRandomVariable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

abstract contract RepairToolERC721Base is
    ERC721Enumerable,
    RepairToolRandomVariable
{
    using Strings for uint256;
    string internal baseURI;

    event ToolValue(uint256 _toolValue);

    function setBaseURI(string memory _newBaseURI) internal {
        baseURI = _newBaseURI;
    }

    /**
     * @return Uri of repair tool contract
     */
    function getBaseURI() public view returns (string memory) {
        return baseURI;
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
}
