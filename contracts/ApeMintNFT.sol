// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./interfaces/IHAYC.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ApeMintNFT is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public tokenContract;
    address public nftContract;
    uint public mintPrice;

    constructor(address _tokenContract, address _nftContract, uint _mintPrice) {
        tokenContract = _tokenContract;
        nftContract = _nftContract;
        mintPrice = _mintPrice;
    }

    // public mint 
    function mintPublic(uint numHAYC) public payable {
        require(numHAYC > 0, "Must mint at least one");
        require(IHAYC(nftContract).isPublicSaleActive() == true, "Public sale is not open");
        IERC20(tokenContract).safeTransferFrom(msg.sender, address(this), mintPrice * numHAYC);
        uint tokenId = IHAYC(nftContract).getLastTokenId();
        uint ethAmount = numHAYC * 0.1;
        IHAYC(nftContract).mint{ value: ethAmount ether }(numHAYC);
        for (uint i=1; i <= numHAYC; i++) {
            IHAYC(nftContract).transferFrom(address(this), msg.sender, tokenID+i);
        }
    }

    // community mint
    function mintCommunity(uint numHAYC, bytes32[] calldata merkleProof)  public payable {
        require(numHAYC > 0, "Must mint at least one");
        require(IHAYC(nftContract).isPublicSaleActive() == true, "Public sale is not open");
        IERC20(tokenContract).safeTransferFrom(msg.sender, address(this), mintPrice * numHAYC);
        uint tokenId = IHAYC(nftContract).getLastTokenId();
        uint ethAmount = numHAYC * 0.07;
        IHAYC(nftContract).mintCommunitySale{ value: ethAmount ether }(numHAYC, merkleProof);
        for (uint i=1; i <= numHAYC; i++) {
            IHAYC(nftContract).transferFrom(address(this), msg.sender, tokenID+i);
        }
    }

    // 取回 eth
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // 取回 token
    function withdrawTokens(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }
}