import { ethers } from 'hardhat'
import { DeployFunction } from 'hardhat-deploy/types'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { getNamedAccounts, deployments } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    await deploy('DropMetadataRenderer', {
        from: deployer,
        args: [],
        log: true,
    })

    await deploy('EditionMetadataRenderer', {
        from: deployer,
        args: [],
        log: true,
    })

    await deploy('NFTCreatorV1', {
        from: deployer,
        args: [0, '0x0000000000000000000000000000000000000000'],
        log: true,
    })
}

func.id = 'deploy'
func.tags = ['all']

export default func
