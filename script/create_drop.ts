import { ethers } from "hardhat"

import { utils } from "ethers"

import { NFTCreatorV1, DropMetadataRenderer, ERC721Drop__factory } from "../typechain"

async function main() {
    const renderer = (await ethers.getContract("DropMetadataRenderer")) as DropMetadataRenderer
    const metadataInitializer = utils.defaultAbiCoder.encode(
        ["string", "string"],
        ["https://nft.asset/", ""]
    )

    const setSaleInterface = new ethers.utils.Interface([
    `function setSaleConfiguration(
        uint104 publicSalePrice,
        uint32 maxSalePurchasePerAddress,
        uint64 publicSaleStart,
        uint64 publicSaleEnd,
        uint64 presaleStart,
        uint64 presaleEnd,
        bytes32 presaleMerkleRoot
    )`]);
    const setupCalls = setSaleInterface.encodeFunctionData(
        'setSaleConfiguration',
        [
            0, // publicSalePrice
            10, // maxSalePurchasePerAddress
            1, // publicSaleStart
            9999999999, // publicSaleEnd
            0, // presaleStart
            0, // presaleEnd
            `0x${"0".repeat(64)}` // presaleMerkleRoot
        ] 
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
        [setupCalls],
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
