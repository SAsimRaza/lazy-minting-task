// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface INftStore {
    error InsufficientBalance();
    error UnAuthorized();
    error TokenIdAlreadyExist();
    error SignatureNotValid();

    event RedeemVoucher(address claimer, NFTVoucher nft, uint256 timestamp);
    event PaymentWithdrawn(address signer, uint256 amount, uint256 timestamp);
    event GovernanceUpdated(
        address oldAdmin,
        address newAdmin,
        uint256 timestamp
    );

    struct NFTVoucher {
        uint256 tokenId;
        uint256 price;
        string metadataUri;
    }

    /// @notice use for redeem voucher
    /// @param _claimer The user address who wants to redeem voucher
    /// @param _data NFTVoucher struct which contains details of NFT voucher
    /// @param _signature signature of NFT creator
    function reedemVoucher(
        address _claimer,
        NFTVoucher memory _data,
        bytes calldata _signature
    ) external payable;

    /// @notice use for withdraw Eth amount
    /// @notice withdraw payments can do by NFT Creator (signer in our case)
    function withdrawPayments() external;

    /// @notice use for transfer ownership of governance
    /// @notice transfer ownership can do by NFT Creator (signer in our case)
    /// @param _signer new signer address
    function transferGovernance(address _signer) external;

    /// @notice use to read contract states
    function getContractStates()
        external
        view
        returns (address, uint256, uint256);
}
