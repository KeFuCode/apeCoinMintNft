// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IHAYC {
    // totalSupply
    function getLastTokenId() external view returns (uint256);
    // public mint
    function mint(uint256 numberOfTokens) external payable;
    // community mint
    function mintCommunitySale(uint8 numberOfTokens, bytes32[] calldata merkleProof) external payable;
    // transferFrom
    function transferFrom(address from, address to, uint256 tokenId) external;
}