const { ethers, network } = require("hardhat")

const networkConfig = {
    default: {
        name: "hardhat",
    },
    31337: {
        name: "localhost",
        subscriptionId: "0",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
        callbackLimit: "500000", // 500,000 gas,
        mintFee: ethers.utils.parseEther("0.02"),
    },
    5: {
        name: "goerli",
        subscriptionId: "10674",
        gasLane:
            "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        interval: "30",
        callbackLimit: "500000",
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        mintFee: ethers.utils.parseEther("0.02"),
    },
    1: {
        name: "mainnet",
    },
}
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
