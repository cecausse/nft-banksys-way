// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./RandomlyAssigned.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract BanksysWayWhitelist is RandomlyAssigned {
    /**
     * @dev MerkleRoot is a hash tree to make a whitelist off-chain
     */
    bytes32 public merkleRoot;
    mapping(address => bool) public whitelistClaimed;

    function setWhitelist(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice Whitelist mint function, whitelisted can only buy one NFT with 10% off
     */
    function whitelistMint(bytes32[] calldata _merkleProof)
        external
        payable
        ensureAvailability
    {
        require(
            startAt <= block.timestamp && startAt != 0,
            "Sell has not begin yet"
        );
        require(!whitelistClaimed[msg.sender], "Already claimed");
        require(!paused, "Paused");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalide proof"
        );
        uint256 newTokenId = nextToken();
        (uint256 currentPrice, uint256 levelOfDestroy) = getAuctionData();
        currentPrice = currentPrice - ((currentPrice * 10) / 100);
        require(msg.value >= currentPrice, "ETH < price");
        whitelistClaimed[msg.sender] = true;
        _safeMint(msg.sender, newTokenId);
        _destroyLevel[newTokenId] = levelOfDestroy;
        _countPerLevel[levelOfDestroy] += 1;
    }
}
