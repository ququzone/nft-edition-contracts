import { ethers } from "hardhat"

import { utils } from "ethers"

import { NFTCreatorV1, DropMetadataRenderer } from "../typechain"

async function main() {
    const renderer = (await ethers.getContract("DropMetadataRenderer")) as DropMetadataRenderer
    const metadataInitializer = utils.defaultAbiCoder.encode(
        ["string", "string"],
        ["https://nft.asset/", ""]
    )

    const user = new ethers.Wallet(process.env.USER_KEY!, ethers.provider)
    const creator = (await ethers.getContract("NFTCreatorV1")) as NFTCreatorV1
    const nft = await creator.connect(user).createAndConfigureDrop(
        renderer.address,
        "test nft",
        "TNF",
        user.address, // admin
        1000,
        500, // 5%
        user.address, // fundsRecipient
        [],
        metadataInitializer
    )

    const receipt = await nft.wait()
    console.log(`created nft address: ${receipt.events![0].address}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
