// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IMetadataRenderer} from "./interfaces/IMetadataRenderer.sol";
import {ERC721Drop} from "./ERC721Drop.sol";

contract NFTCreatorV1 is Ownable {
    event CreatedDrop(address indexed creator, address indexed editionContractAddress, uint256 editionSize);

    uint256 public mintFee;
    address payable public mintFeeRecipient;

    constructor(uint256 _mintFee, address payable _mintFeeRecipient) {
        mintFee = _mintFee;
        mintFeeRecipient = _mintFeeRecipient;
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    function setmintFeeRecipient(address payable _mintFeeRecipient) external onlyOwner {
        mintFeeRecipient = _mintFeeRecipient;
    }

    function createAndConfigureDrop(
        IMetadataRenderer metadataRenderer,
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        bytes[] memory setupCalls,
        bytes memory metadataInitializer
    ) public returns (ERC721Drop) {
        ERC721Drop drop = new ERC721Drop(mintFee, mintFeeRecipient, name, symbol, defaultAdmin, fundsRecipient);
        drop.initConfig({
            _setupCalls: setupCalls,
            _editionSize: editionSize,
            _royaltyBPS: royaltyBPS,
            _metadataRenderer: metadataRenderer,
            _metadataRendererInit: metadataInitializer
        });
        return drop;
    }
}
