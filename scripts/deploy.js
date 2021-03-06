const hre = require("hardhat");

async function main() {
    const ApeMintNFT = await hre.ethers.getContractFactory("ApeMintNFT");
    const apemintnft = await ApeMintNFT.deploy(
        "0x4362C6c8A50924BE4125757D7A0277e977a4584B",
        "0x60907E5037e608DAF063E81060D397e91D460881",
        hre.ethers.BigNumber.from("15000000000000000000")
    );

    await apemintnft.deployed();

    console.log("ApeMintNFT deployed to:", apemintnft.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});