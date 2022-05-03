// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./IHAYC.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ApeMintNFT is IERC721Receiver, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public tokenContract;
    address public nftContract;
    uint public mintPrice;

    constructor(
        address _tokenContract,
        address _nftContract,
        uint _mintPrice
    ) {
        tokenContract = _tokenContract;
        nftContract = _nftContract;
        mintPrice = _mintPrice;
    }

    // deposit eth to contract
    function deposit() external payable {}

    // get eth balance
    function getBalnce() external view returns (uint) {
        return address(this).balance;
    }

    // get ape balance
    function getTokenBalance() external view returns (uint) {
        return IERC20(tokenContract).balanceOf(address(this));
    }

    // public mint
    function mintPublic(uint numHAYC) public {
        require(numHAYC > 0, "Must mint at least one");
        IERC20(tokenContract).safeTransferFrom(
            msg.sender,
            address(this),
            mintPrice * numHAYC
        );
        uint tokenId = IHAYC(nftContract).getLastTokenId();
        IHAYC(nftContract).mint{value: numHAYC * 0.001 ether}(numHAYC);
        for (uint i = 1; i <= numHAYC; i++) {
            IHAYC(nftContract).transferFrom(
                address(this),
                msg.sender,
                tokenId + i
            );
        }
    }

    // community mint
    function mintCommunity(uint8 numHAYC, bytes32[] calldata merkleProof)
        public
    {
        require(numHAYC > 0, "Must mint at least one");
        IERC20(tokenContract).safeTransferFrom(
            msg.sender,
            address(this),
            mintPrice * numHAYC
        );
        uint tokenId = IHAYC(nftContract).getLastTokenId();
        IHAYC(nftContract).mintCommunitySale{value: numHAYC * 0.0007 ether}(
            numHAYC,
            merkleProof
        );
        for (uint i = 1; i <= numHAYC; i++) {
            IHAYC(nftContract).transferFrom(
                address(this),
                msg.sender,
                tokenId + i
            );
        }
    }

    // receive erc721
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // withdraw eth
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // withdraw token
    function withdrawTokens(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }
}
