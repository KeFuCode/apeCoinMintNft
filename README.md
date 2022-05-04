# 使用$Ape铸造NFT
## 开发环境
**hardhat**  
官网：https://hardhat.org/getting-started/  
智能合约本地开发工具，提供大量插件，可实现方便快速的测试案例。  
需要用到 package 如下： 
```json
  "dependencies": {
    "@openzeppelin/contracts": "^4.6.0",
    "dotenv": "^16.0.0",
  },
  "devDependencies": {
    "@nomiclabs/hardhat-ethers": "^2.0.0",
    "@nomiclabs/hardhat-etherscan": "^3.0.3",
    "@nomiclabs/hardhat-waffle": "^2.0.0",
    "chai": "^4.2.0",
    "ethereum-waffle": "^3.0.0",
    "ethers": "^5.0.0",
    "hardhat": "^2.9.3"
  }
```     
**remix**  
在线 IDE ：https://remix.ethereum.org/  
借助 remix，实现合约功能的快速部署、测试。
## 依赖
```solidity
// 需要调用 HAYC.sol 中的部分函数
import "./interfaces/IHAYC.sol";
// 合约接收ERC20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// 合约接收ERC721
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// 合约所有权
import "@openzeppelin/contracts/access/Ownable.sol";
// 防重入攻击
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
```
## 数据结构
```solidity
    // token合约地址
    address public tokenContract;
    // nft合约地址
    address public nftContract;
    // 铸造NFT需要的token数量
    uint public mintPrice;
```
## 功能实现
构造函数，赋初值
```solidity
    constructor(
        address _tokenContract,
        address _nftContract,
        uint _mintPrice
    ) {
        tokenContract = _tokenContract;
        nftContract = _nftContract;
        mintPrice = _mintPrice;
    }
```
主要功能
```solidity
    // 向合约存入eth，用于铸造nft
    // deposit eth to contract
    function deposit() external payable {}

    // 查询合约内eth和token的余额
    // get eth balance
    function getBalnce() external view returns (uint) {
        return address(this).balance;
    }
    // get ape balance
    function getTokenBalance() external view returns (uint) {
        return IERC20(tokenContract).balanceOf(address(this));
    }

    // 两种方式铸造nft：公售，白名单销售
    // public mint
    function mintPublic(uint numHAYC) public {
        require(numHAYC > 0, "Must mint at least one");
        IERC20(tokenContract).safeTransferFrom(
            msg.sender,
            address(this),
            mintPrice * numHAYC
        );
        uint tokenId = IHAYC(nftContract).getLastTokenId();
        IHAYC(nftContract).mint{value: numHAYC * 0.1 ether}(numHAYC);
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
        IHAYC(nftContract).mintCommunitySale{value: numHAYC * 0.07 ether}(
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

    // 重写onERC721Received,实现合约接收nft功能
    // receive erc721
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // 从合约中取款
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
```
## 错误
**报错1**  
`execution reverted: ERC721: transfer to non ERC721Receiver implementer`
```json
Gas estimation errored with the following message (see below). The transaction execution will likely fail. Do you want to force sending?
execution reverted: ERC721: transfer to non ERC721Receiver implementer { "originalError": { "code": 3, "data": "0x08c379a0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000324552433732313a207472616e7366657220746f206e6f6e20455243373231526563656976657220696d706c656d656e7465720000000000000000000000000000", "message": "execution reverted: ERC721: transfer to non ERC721Receiver implementer" }
```
解决方案
```solidity
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ApeMintNFT is IERC721Receiver, Ownable, ReentrancyGuard {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
```
