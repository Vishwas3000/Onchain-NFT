const { network, ethers } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const chainId = network.config.chainId

    const args = []

    log("----------------")
    const basicNFT = await deploy("BasicNFT", {
        from: deployer,
        args: args,
        log: true,
        waitConformations: network.config.blockConformations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...")
        await verify(basicNFT.address, args)
    }
}

module.exports.tags = ["all", "basicnft", "main"]
