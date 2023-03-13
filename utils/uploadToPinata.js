const pinataSDK = require("@pinata/sdk")
const fs = require("fs")
const path = require("path")
require("dotenv").config()

const pinataApiKey = process.env.PINATA_API_KEY
const pinataSecretKey = process.env.PINATA_API_SECRET_KEY
const pinata = new pinataSDK(pinataApiKey, pinataSecretKey)

async function storeImages(imagesFilePath) {
    const fullImagesPath = path.resolve(imagesFilePath)
    const files = fs.readdirSync(fullImagesPath)

    let responses = []

    console.log("Uploading to IPFS...")

    for (fileIndex in files) {
        const readableStreamForFile = fs.createReadStream(
            `${fullImagesPath}/${files[fileIndex]}`
        )
        const options = {
            pinataMetadata: {
                name: files[fileIndex],
            },
        }
        try {
            const response = await pinata.pinFileToIPFS(
                readableStreamForFile,
                options
            )
            responses.push(response)
        } catch (error) {
            console.log(error)
        }
    }
    return { responses, files }
}

async function storeTokenUriMetadata(metadata) {
    const options = {
        pinataMetadata: {
            name: metadata.name,
        },
    }
    try {
        const response = await pinata.pinJSONToIPFS(metadata, options)
        return response
    } catch (error) {
        console.log(error)
    }
    return null
}

module.exports = { storeImages, storeTokenUriMetadata }
