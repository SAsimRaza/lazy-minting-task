// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./INftStore.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title Task of Lazy Minting
/// @author Asim Raza
/// @notice You can use this contract for only redeem voucher
/// @dev All function calls are currently implemented without side effects
contract NftStore is ERC721URIStorage, INftStore {
    using ECDSA for bytes32;

    address signer;

    uint256 vouchersDistributed;
    uint256 ethTobeWithdraw;

    constructor(address _signer) ERC721("NFT Store", "NFT") {
        signer = _signer;
    }

    /// @inheritdoc INftStore
    function reedemVoucher(
        address _claimer,
        NFTVoucher memory message,
        bytes calldata signature
    ) external payable override {
        if (_exists(message.tokenId)) {
            revert TokenIdAlreadyExist();
        }

        if (msg.value < message.price) {
            revert InsufficientBalance();
        }

        _recSig(message, signature);

        ethTobeWithdraw += msg.value;

        _mint(_claimer, message.tokenId);
        _setTokenURI(message.tokenId, message.metadataUri);

        unchecked {
            vouchersDistributed++;
        }

        emit RedeemVoucher(_claimer, message, block.timestamp);
    }

    /// @inheritdoc INftStore
    function withdrawPayments() external override {
        if (msg.sender != signer) {
            revert UnAuthorized();
        }

        if (ethTobeWithdraw <= 0) {
            revert InsufficientBalance();
        }

        uint256 pendingAmount = ethTobeWithdraw;
        ethTobeWithdraw = 0;
        payable(msg.sender).transfer(pendingAmount);

        emit PaymentWithdrawn(signer, pendingAmount, block.timestamp);
    }

    /// @inheritdoc INftStore
    function transferGovernance(address _signer) external override {
        if (msg.sender != signer) {
            revert UnAuthorized();
        }

        emit GovernanceUpdated(signer, signer = _signer, block.timestamp);
    }

    /// @inheritdoc INftStore
    function getContractStates()
        external
        view
        override
        returns (address, uint256, uint256)
    {
        return (signer, vouchersDistributed, ethTobeWithdraw);
    }

    function _recSig(
        NFTVoucher memory message,
        bytes calldata signature
    ) internal view {
        bytes32 signedMessageHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();

        if (signedMessageHash.recover(signature) != signer) {
            revert SignatureNotValid();
        }
    }
}
