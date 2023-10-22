// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Standard libraries
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

// ERC-6551 references
import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/interfaces/IERC6551Account.sol";
import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/lib/ERC6551AccountLib.sol";
import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/ERC6551Registry.sol";

/**
 * @title SimpleERC6551Account
 * @dev A smart contract implementing the ERC-6551 (Token Bound Accounts) standard for NFT accounts.
 */
contract SimpleERC6551Account is IERC165, IERC1271, IERC6551Account {
    uint256 public nonce;

    receive() external payable {}

    /**
     * @dev Execute a call to an external (token bound account) contract.
     * @param to The address of the external contract.
     * @param value The amount of Ether to send with the call.
     * @param data The data to include in the call.
     * @return result The result of the external contract call.
     */
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result) {
        require(msg.sender == owner(), "Not token owner");
        ++nonce;

        emit TransactionExecuted(to, value, data);

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    /**
     * @dev Get information about the NFT associated with this account.
     * @return tokenID The ID of the NFT.
     * @return chain The chain on which the NFT is deployed.
     * @return nftAddress The address of the NFT.
     */
    function token()
        external
        view
        returns (
            uint256, // tokenID
            address, // chain the nft is deployed on
            uint256 // address of the NFT
        )
    {
        return ERC6551AccountLib.token();
    }

    /**
     * @dev Get the owner of the NFT.
     * @return The address of the NFT owner.
     */
    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        if (chainId != block.chainid) {
            return address(0);
        }
        return IERC721(tokenContract).ownerOf(tokenId);
    }

    /**
     * @dev Check if the contract supports the ERC-6551 interface.
     * @param interfaceId The interface ID to check.
     * @return A boolean indicating whether the contract supports the interface.
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    /**
     * @dev Check the validity of a signature.
     * @param hash The hash to be verified.
     * @param signature The signature to be verified.
     * @return magicValue The magic value indicating the validity of the signature.
     */
    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(
            owner(),
            hash,
            signature
        );

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }
}
