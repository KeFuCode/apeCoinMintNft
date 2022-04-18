const hre = require("hardhat");

async function main() {
  // 编译合约  
  await hre.run('compile');

  // We get the contract to deploy
  const SwapExample = await hre.ethers.getContractFactory("SwapExample");
  const swapExample = await SwapExample.deploy("0xE592427A0AEce92De3Edee1F18E0157C05861564");

  await swapExample.deployed();

  console.log("SwapExample deployed to:", swapExample.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
