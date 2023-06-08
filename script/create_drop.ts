import { ethers } from "hardhat"

import { NFTCreatorV1 } from "../typechain"

async function main() {
    const user = new ethers.Wallet(process.env.USER_KEY!, ethers.provider)
    const creator = (await ethers.getContract("NFTCreatorV1")) as NFTCreatorV1

    const nft = await creator.connect(user).createDrop(
        "test nft",   // name
        "TNF",        // symbol
        user.address, // admin
        1000,         // editionSize
        500,          // 5% royaltyBPS
        user.address, // fundsRecipient
        {
            publicSalePrice: 0,
            maxSalePurchasePerAddress: 10,
            publicSaleStart: 1,
            publicSaleEnd: 9999999999,
            presaleStart: 0,
            presaleEnd: 0,
            presaleMerkleRoot: `0x${"0".repeat(64)}`
        },
        "https://nft.asset/", // metadataURIBase
        ""                    // metadataContractURI
    )

    const receipt = await nft.wait()
    console.log(`created drop nft address: ${receipt.events![receipt.events!.length - 1].args![1]}`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
