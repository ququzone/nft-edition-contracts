// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC721A, ERC721A} from "erc721a/contracts/ERC721A.sol";
import {IERC2981, IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {IERC4906} from "./interfaces/IERC4906.sol";
import {IERC721Drop} from "./interfaces/IERC721Drop.sol";
import {IOwnable} from "./interfaces/IOwnable.sol";
import {IMetadataRenderer} from "./interfaces/IMetadataRenderer.sol";
import {PublicMulticall} from "./utils/PublicMulticall.sol";
import {OwnableSkeleton} from "./utils/OwnableSkeleton.sol";
import {FundsReceiver} from "./utils/FundsReceiver.sol";
import {ERC721DropStorageV1} from "./storage/ERC721DropStorageV1.sol";

contract ERC721Drop is
    IERC721Drop,
    ERC721A,
    IERC2981,
    IERC4906,
    ReentrancyGuard,
    AccessControl,
    PublicMulticall,
    OwnableSkeleton,
    FundsReceiver,
    ERC721DropStorageV1
{
    /// @dev This is the max mint batch size for the optimized ERC721A mint contract
    uint256 internal immutable MAX_MINT_BATCH_SIZE = 8;

    /// @dev Gas limit to send funds
    uint256 internal immutable FUNDS_SEND_GAS_LIMIT = 210_000;

    /// @notice Access control roles
    bytes32 public immutable MINTER_ROLE = keccak256("MINTER");
    bytes32 public immutable SALES_MANAGER_ROLE = keccak256("SALES_MANAGER");

    /// @notice Mint Fee
    uint256 public immutable MIMO_MINT_FEE;
    /// @notice Mint Fee Recipient
    address payable public immutable MIMO_MINT_FEE_RECIPIENT;

    /// @notice Max royalty BPS
    uint16 constant MAX_ROYALTY_BPS = 50_00;

    /// @notice Only allow for users with admin access
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            revert Access_OnlyAdmin();
        }

        _;
    }

    /// @notice Only a given role has access or admin
    /// @param role role to check for alongside the admin role
    modifier onlyRoleOrAdmin(bytes32 role) {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) && !hasRole(role, _msgSender())) {
            revert Access_MissingRoleOrAdmin(role);
        }

        _;
    }

    /// @notice Allows user to mint tokens at a quantity
    modifier canMintTokens(uint256 quantity) {
        if (quantity + _totalMinted() > config.editionSize) {
            revert Mint_SoldOut();
        }

        _;
    }

    function _presaleActive() internal view returns (bool) {
        return salesConfig.presaleStart <= block.timestamp && salesConfig.presaleEnd > block.timestamp;
    }

    function _publicSaleActive() internal view returns (bool) {
        return salesConfig.publicSaleStart <= block.timestamp && salesConfig.publicSaleEnd > block.timestamp;
    }

    /// @notice Presale active
    modifier onlyPresaleActive() {
        if (!_presaleActive()) {
            revert Presale_Inactive();
        }

        _;
    }

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Start token ID for minting (1-100 vs 0-99)
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    constructor(
        uint256 _mintFeeAmount,
        address payable _mintFeeRecipient,
        string memory _contractName,
        string memory _contractSymbol,
        address _initialOwner,
        bytes[] memory _setupCalls
    ) ERC721A(_contractName, _contractSymbol) {
        MIMO_MINT_FEE = _mintFeeAmount;
        MIMO_MINT_FEE_RECIPIENT = _mintFeeRecipient;

        // Setup the owner role
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        // Set ownership to original sender of contract call
        _setOwner(_initialOwner);

        if (_setupCalls.length > 0) {
            // Setup temporary role
            _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
            // Execute setupCalls
            multicall(_setupCalls);
            // Remove temporary role
            _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        }
    }

    function initConfig(
        address payable _fundsRecipient,
        uint64 _editionSize,
        uint16 _royaltyBPS,
        IMetadataRenderer _metadataRenderer,
        bytes memory _metadataRendererInit
    ) external {
        if (_royaltyBPS > MAX_ROYALTY_BPS || config.royaltyBPS > MAX_ROYALTY_BPS) {
            revert Setup_RoyaltyPercentageTooHigh(MAX_ROYALTY_BPS);
        }

        // Setup config variables
        config.editionSize = _editionSize;
        config.metadataRenderer = _metadataRenderer;
        config.royaltyBPS = _royaltyBPS;
        config.fundsRecipient = _fundsRecipient;
        _metadataRenderer.initializeWithData(_metadataRendererInit);
    }

    /// @dev Getter for admin role associated with the contract to handle metadata
    /// @return boolean if address is admin
    function isAdmin(address user) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, user);
    }

    /// @dev Get royalty information for token
    /// @param _salePrice Sale price for the token
    function royaltyInfo(
        uint256,
        uint256 _salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        if (config.fundsRecipient == address(0)) {
            return (config.fundsRecipient, 0);
        }
        return (config.fundsRecipient, (_salePrice * config.royaltyBPS) / 10_000);
    }

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails() external view returns (IERC721Drop.SaleDetails memory) {
        return
            IERC721Drop.SaleDetails({
                publicSaleActive: _publicSaleActive(),
                presaleActive: _presaleActive(),
                publicSalePrice: salesConfig.publicSalePrice,
                publicSaleStart: salesConfig.publicSaleStart,
                publicSaleEnd: salesConfig.publicSaleEnd,
                presaleStart: salesConfig.presaleStart,
                presaleEnd: salesConfig.presaleEnd,
                presaleMerkleRoot: salesConfig.presaleMerkleRoot,
                totalMinted: _totalMinted(),
                maxSupply: config.editionSize,
                maxSalePurchasePerAddress: salesConfig.maxSalePurchasePerAddress
            });
    }

    /// @dev Number of NFTs the user has minted per address
    /// @param minter to get counts for
    function mintedPerAddress(address minter) external view override returns (IERC721Drop.AddressMintDetails memory) {
        return
            IERC721Drop.AddressMintDetails({
                presaleMints: presaleMintsByAddress[minter],
                publicMints: _numberMinted(minter) - presaleMintsByAddress[minter],
                totalMints: _numberMinted(minter)
            });
    }

    /// @notice MIMO fee is fixed now per mint
    /// @dev Gets the mimo fee for amount of withdraw
    function mimoFeeForAmount(uint256 quantity) public view returns (address payable recipient, uint256 fee) {
        recipient = MIMO_MINT_FEE_RECIPIENT;
        fee = MIMO_MINT_FEE * quantity;
    }

    /// @notice Purchase a quantity of tokens
    /// @param quantity quantity to purchase
    /// @return tokenId of the first token minted
    function purchase(
        uint256 quantity
    ) external payable nonReentrant canMintTokens(quantity) onlyPublicSaleActive returns (uint256) {
        return _handlePurchase(quantity, "");
    }

    /// @notice Purchase a quantity of tokens with a comment
    /// @param quantity quantity to purchase
    /// @param comment comment to include in the IERC721Drop.Sale event
    /// @return tokenId of the first token minted
    function purchaseWithComment(
        uint256 quantity,
        string calldata comment
    ) external payable nonReentrant canMintTokens(quantity) onlyPublicSaleActive returns (uint256) {
        return _handlePurchase(quantity, comment);
    }

    /// @notice Function to mint NFTs
    /// @dev (important: Does not enforce max supply limit, enforce that limit earlier)
    /// @dev This batches in size of 8 as per recommended by ERC721A creators
    /// @param to address to mint NFTs to
    /// @param quantity number of NFTs to mint
    function _mintNFTs(address to, uint256 quantity) internal {
        do {
            uint256 toMint = quantity > MAX_MINT_BATCH_SIZE ? MAX_MINT_BATCH_SIZE : quantity;
            _mint({to: to, quantity: toMint});
            quantity -= toMint;
        } while (quantity > 0);
    }

    function _handlePurchase(uint256 quantity, string memory comment) internal returns (uint256) {
        uint256 salePrice = salesConfig.publicSalePrice;

        if (msg.value != (salePrice + MIMO_MINT_FEE) * quantity) {
            revert Purchase_WrongPrice((salePrice + MIMO_MINT_FEE) * quantity);
        }

        // If max purchase per address == 0 there is no limit.
        // Any other number, the per address mint limit is that.
        if (
            salesConfig.maxSalePurchasePerAddress != 0 &&
            _numberMinted(_msgSender()) + quantity - presaleMintsByAddress[_msgSender()] >
            salesConfig.maxSalePurchasePerAddress
        ) {
            revert Purchase_TooManyForAddress();
        }

        uint256 firstMintedTokenId = _nextTokenId();
        _mintNFTs(_msgSender(), quantity);

        _payoutMimoFee(quantity);

        emit IERC721Drop.Sale({
            to: _msgSender(),
            quantity: quantity,
            pricePerToken: salePrice,
            firstPurchasedTokenId: firstMintedTokenId
        });
        if (bytes(comment).length > 0) {
            emit IERC721Drop.MintComment({
                sender: _msgSender(),
                tokenContract: address(this),
                tokenId: firstMintedTokenId,
                quantity: quantity,
                comment: comment
            });
        }
        return firstMintedTokenId;
    }

    /// @notice Merkle-tree based presale purchase function
    /// @param quantity quantity to purchase
    /// @param maxQuantity max quantity that can be purchased via merkle proof #
    /// @param pricePerToken price that each token is purchased at
    /// @param merkleProof proof for presale mint
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] calldata merkleProof
    ) external payable nonReentrant canMintTokens(quantity) onlyPresaleActive returns (uint256) {
        return _handlePurchasePresale(quantity, maxQuantity, pricePerToken, merkleProof, "");
    }

    /// @notice Merkle-tree based presale purchase function with a comment
    /// @param quantity quantity to purchase
    /// @param maxQuantity max quantity that can be purchased via merkle proof #
    /// @param pricePerToken price that each token is purchased at
    /// @param merkleProof proof for presale mint
    /// @param comment comment to include in the IERC721Drop.Sale event
    function purchasePresaleWithComment(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] calldata merkleProof,
        string calldata comment
    ) external payable nonReentrant canMintTokens(quantity) onlyPresaleActive returns (uint256) {
        return _handlePurchasePresale(quantity, maxQuantity, pricePerToken, merkleProof, comment);
    }

    function _handlePurchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] calldata merkleProof,
        string memory comment
    ) internal returns (uint256) {
        if (
            !MerkleProof.verify(
                merkleProof,
                salesConfig.presaleMerkleRoot,
                keccak256(
                    // address, uint256, uint256
                    abi.encode(_msgSender(), maxQuantity, pricePerToken)
                )
            )
        ) {
            revert Presale_MerkleNotApproved();
        }

        if (msg.value != (pricePerToken + MIMO_MINT_FEE) * quantity) {
            revert Purchase_WrongPrice((pricePerToken + MIMO_MINT_FEE) * quantity);
        }

        presaleMintsByAddress[_msgSender()] += quantity;
        if (presaleMintsByAddress[_msgSender()] > maxQuantity) {
            revert Presale_TooManyForAddress();
        }

        uint256 firstMintedTokenId = _nextTokenId();
        _mintNFTs(_msgSender(), quantity);

        _payoutMimoFee(quantity);

        emit IERC721Drop.Sale({
            to: _msgSender(),
            quantity: quantity,
            pricePerToken: pricePerToken,
            firstPurchasedTokenId: firstMintedTokenId
        });
        if (bytes(comment).length > 0) {
            emit IERC721Drop.MintComment({
                sender: _msgSender(),
                tokenContract: address(this),
                tokenId: firstMintedTokenId,
                quantity: quantity,
                comment: comment
            });
        }

        return firstMintedTokenId;
    }

    /// @notice Mint admin
    /// @param recipient recipient to mint to
    /// @param quantity quantity to mint
    function adminMint(
        address recipient,
        uint256 quantity
    ) external onlyRoleOrAdmin(MINTER_ROLE) canMintTokens(quantity) returns (uint256) {
        _mintNFTs(recipient, quantity);

        return _nextTokenId();
    }

    /// @dev This mints multiple editions to the given list of addresses.
    /// @param recipients list of addresses to send the newly minted editions to
    function adminMintAirdrop(
        address[] calldata recipients
    ) external override onlyRoleOrAdmin(MINTER_ROLE) canMintTokens(recipients.length) returns (uint256) {
        uint256 atId = _nextTokenId();
        uint256 startAt = atId;

        unchecked {
            for (uint256 endAt = atId + recipients.length; atId < endAt; atId++) {
                _mintNFTs(recipients[atId - startAt], 1);
            }
        }
        return _nextTokenId();
    }

    /// @dev Set new owner for royalties / opensea
    /// @param newOwner new owner to set
    function setOwner(address newOwner) public onlyAdmin {
        _setOwner(newOwner);
    }

    /// @notice Set a new metadata renderer
    /// @param newRenderer new renderer address to use
    /// @param setupRenderer data to setup new renderer with
    function setMetadataRenderer(IMetadataRenderer newRenderer, bytes memory setupRenderer) external onlyAdmin {
        config.metadataRenderer = newRenderer;

        if (setupRenderer.length > 0) {
            newRenderer.initializeWithData(setupRenderer);
        }

        emit UpdatedMetadataRenderer({sender: _msgSender(), renderer: newRenderer});

        _notifyMetadataUpdate();
    }

    /// @notice Calls the metadata renderer contract to make an update and uses the EIP4906 event to notify
    /// @param data raw calldata to call the metadata renderer contract with.
    /// @dev Only accessible via an admin role
    function callMetadataRenderer(bytes memory data) public onlyAdmin returns (bytes memory) {
        (bool success, bytes memory response) = address(config.metadataRenderer).call(data);
        if (!success) {
            revert ExternalMetadataRenderer_CallFailed();
        }
        _notifyMetadataUpdate();
        return response;
    }

    /// @dev This sets the sales configuration
    /// @param publicSalePrice New public sale price
    /// @param maxSalePurchasePerAddress Max # of purchases (public) per address allowed
    /// @param publicSaleStart unix timestamp when the public sale starts
    /// @param publicSaleEnd unix timestamp when the public sale ends (set to 0 to disable)
    /// @param presaleStart unix timestamp when the presale starts
    /// @param presaleEnd unix timestamp when the presale ends
    /// @param presaleMerkleRoot merkle root for the presale information
    function setSaleConfiguration(
        uint104 publicSalePrice,
        uint32 maxSalePurchasePerAddress,
        uint64 publicSaleStart,
        uint64 publicSaleEnd,
        uint64 presaleStart,
        uint64 presaleEnd,
        bytes32 presaleMerkleRoot
    ) external onlyRoleOrAdmin(SALES_MANAGER_ROLE) {
        salesConfig.publicSalePrice = publicSalePrice;
        salesConfig.maxSalePurchasePerAddress = maxSalePurchasePerAddress;
        salesConfig.publicSaleStart = publicSaleStart;
        salesConfig.publicSaleEnd = publicSaleEnd;
        salesConfig.presaleStart = presaleStart;
        salesConfig.presaleEnd = presaleEnd;
        salesConfig.presaleMerkleRoot = presaleMerkleRoot;

        emit SalesConfigChanged(_msgSender());
    }

    /// @notice Set a different funds recipient
    /// @param newRecipientAddress new funds recipient address
    function setFundsRecipient(address payable newRecipientAddress) external onlyRoleOrAdmin(SALES_MANAGER_ROLE) {
        // TODO(iain): funds recipient cannot be 0?
        config.fundsRecipient = newRecipientAddress;
        emit FundsRecipientChanged(newRecipientAddress, _msgSender());
    }

    /// @notice This withdraws ETH from the contract to the contract owner.
    function withdraw() external nonReentrant {
        address sender = _msgSender();

        uint256 funds = address(this).balance;

        // Check if withdraw is allowed for sender
        if (
            !hasRole(DEFAULT_ADMIN_ROLE, sender) &&
            !hasRole(SALES_MANAGER_ROLE, sender) &&
            sender != config.fundsRecipient
        ) {
            revert Access_WithdrawNotAllowed();
        }

        // Payout recipient
        (bool successFunds, ) = config.fundsRecipient.call{value: funds, gas: FUNDS_SEND_GAS_LIMIT}("");
        if (!successFunds) {
            revert Withdraw_FundsSendFailure();
        }

        // Emit event for indexing
        emit FundsWithdrawn(_msgSender(), config.fundsRecipient, funds, address(0), 0);
    }

    /// @notice Admin function to finalize and open edition sale
    function finalizeOpenEdition() external onlyRoleOrAdmin(SALES_MANAGER_ROLE) {
        if (config.editionSize != type(uint64).max) {
            revert Admin_UnableToFinalizeNotOpenEdition();
        }

        config.editionSize = uint64(_totalMinted());
        emit OpenMintFinalized(_msgSender(), config.editionSize);
    }

    /// @notice Simple override for owner interface.
    /// @return user owner address
    function owner() public view override(OwnableSkeleton, IERC721Drop) returns (address) {
        return super.owner();
    }

    /// @notice Contract URI Getter, proxies to metadataRenderer
    /// @return Contract URI
    function contractURI() external view returns (string memory) {
        return config.metadataRenderer.contractURI();
    }

    /// @notice Getter for metadataRenderer contract
    function metadataRenderer() external view returns (IMetadataRenderer) {
        return IMetadataRenderer(config.metadataRenderer);
    }

    /// @notice Token URI Getter, proxies to metadataRenderer
    /// @param tokenId id of token to get URI for
    /// @return Token URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert IERC721A.URIQueryForNonexistentToken();
        }

        return config.metadataRenderer.tokenURI(tokenId);
    }

    /// @notice Internal function to notify that all metadata may/was updated in the update
    /// @dev Since we don't know what tokens were updated, most calls to a metadata renderer
    ///      update the metadata we can assume all tokens metadata changed
    function _notifyMetadataUpdate() internal {
        uint256 totalMinted = _totalMinted();

        // If we have tokens to notify about
        if (totalMinted > 0) {
            emit BatchMetadataUpdate(_startTokenId(), totalMinted + _startTokenId());
        }
    }

    function _payoutMimoFee(uint256 quantity) internal {
        // Transfer MIMO fee to recipient
        (, uint256 mimoFee) = mimoFeeForAmount(quantity);
        (bool success, ) = MIMO_MINT_FEE_RECIPIENT.call{value: mimoFee, gas: FUNDS_SEND_GAS_LIMIT}("");
        emit MintFeePayout(mimoFee, MIMO_MINT_FEE_RECIPIENT, success);
    }

    /// @notice ERC165 supports interface
    /// @param interfaceId interface id to check if supported
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(IERC165, ERC721A, AccessControl) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            type(IOwnable).interfaceId == interfaceId ||
            type(IERC2981).interfaceId == interfaceId ||
            // Because the EIP-4906 spec is event-based a numerically relevant interfaceId is used.
            bytes4(0x49064906) == interfaceId ||
            type(IERC721Drop).interfaceId == interfaceId;
    }
}
