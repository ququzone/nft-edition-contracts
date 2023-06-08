// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IMetadataRenderer} from "./interfaces/IMetadataRenderer.sol";
import {EditionMetadataRenderer} from "./metadata/EditionMetadataRenderer.sol";
import {DropMetadataRenderer} from "./metadata/DropMetadataRenderer.sol";
import {IERC721Drop, ERC721Drop} from "./ERC721Drop.sol";

contract NFTCreatorV1 is Ownable {
    event CreatedDrop(address indexed creator, address indexed editionContractAddress, uint256 editionSize);

    uint256 public mintFee;
    address payable public mintFeeRecipient;

    EditionMetadataRenderer public immutable editionMetadataRenderer;
    DropMetadataRenderer public immutable dropMetadataRenderer;

    constructor(
        uint256 _mintFee,
        address payable _mintFeeRecipient,
        EditionMetadataRenderer _editionMetadataRenderer,
        DropMetadataRenderer _dropMetadataRenderer
    ) {
        mintFee = _mintFee;
        mintFeeRecipient = _mintFeeRecipient;
        editionMetadataRenderer = _editionMetadataRenderer;
        dropMetadataRenderer = _dropMetadataRenderer;
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    function setmintFeeRecipient(address payable _mintFeeRecipient) external onlyOwner {
        mintFeeRecipient = _mintFeeRecipient;
    }

    function createAndConfigureDrop(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        bytes[] memory setupCalls,
        IMetadataRenderer metadataRenderer,
        bytes memory metadataInitializer
    ) public returns (address payable) {
        ERC721Drop drop = new ERC721Drop(mintFee, mintFeeRecipient, name, symbol, defaultAdmin, fundsRecipient);
        drop.initConfig({
            _setupCalls: setupCalls,
            _editionSize: editionSize,
            _royaltyBPS: royaltyBPS,
            _metadataRenderer: metadataRenderer,
            _metadataRendererInit: metadataInitializer
        });
        return payable(address(drop));
    }

    function setupDropsContract(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        address payable fundsRecipient,
        uint64 editionSize,
        uint16 royaltyBPS,
        IERC721Drop.SalesConfiguration memory saleConfig,
        IMetadataRenderer metadataRenderer,
        bytes memory metadataInitializer
    ) public returns (address) {
        bytes[] memory setupData = new bytes[](1);
        setupData[0] = abi.encodeWithSelector(
            ERC721Drop.setSaleConfiguration.selector,
            saleConfig.publicSalePrice,
            saleConfig.maxSalePurchasePerAddress,
            saleConfig.publicSaleStart,
            saleConfig.publicSaleEnd,
            saleConfig.presaleStart,
            saleConfig.presaleEnd,
            saleConfig.presaleMerkleRoot
        );
        address newDropAddress = createAndConfigureDrop({
            name: name,
            symbol: symbol,
            defaultAdmin: defaultAdmin,
            fundsRecipient: fundsRecipient,
            editionSize: editionSize,
            royaltyBPS: royaltyBPS,
            setupCalls: setupData,
            metadataRenderer: metadataRenderer,
            metadataInitializer: metadataInitializer
        });

        emit CreatedDrop({creator: msg.sender, editionSize: editionSize, editionContractAddress: newDropAddress});

        return newDropAddress;
    }

    function createDrop(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        IERC721Drop.SalesConfiguration memory saleConfig,
        string memory metadataURIBase,
        string memory metadataContractURI
    ) external returns (address) {
        bytes memory metadataInitializer = abi.encode(metadataURIBase, metadataContractURI);
        return
            setupDropsContract({
                defaultAdmin: defaultAdmin,
                name: name,
                symbol: symbol,
                royaltyBPS: royaltyBPS,
                editionSize: editionSize,
                fundsRecipient: fundsRecipient,
                saleConfig: saleConfig,
                metadataRenderer: dropMetadataRenderer,
                metadataInitializer: metadataInitializer
            });
    }

    function createEdition(
        string memory name,
        string memory symbol,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        address defaultAdmin,
        IERC721Drop.SalesConfiguration memory saleConfig,
        string memory description,
        string memory animationURI,
        string memory imageURI
    ) external returns (address) {
        bytes memory metadataInitializer = abi.encode(description, imageURI, animationURI);

        return
            setupDropsContract({
                name: name,
                symbol: symbol,
                defaultAdmin: defaultAdmin,
                editionSize: editionSize,
                royaltyBPS: royaltyBPS,
                saleConfig: saleConfig,
                fundsRecipient: fundsRecipient,
                metadataRenderer: editionMetadataRenderer,
                metadataInitializer: metadataInitializer
            });
    }
}
