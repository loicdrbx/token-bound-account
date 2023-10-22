// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/interfaces/IERC6551Registry.sol";
import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/lib/ERC6551AccountLib.sol";

/**
 * @title NFT
 * @dev A smart contract for creating and managing ERC721 Non-Fungible Tokens (NFTs) 
 *      with the additional functionality required by token bound accounts.
 */
contract NFT is ERC721, Ownable {

    // State variables
    uint256 public totalSupply;
    address public immutable tokenContract = address(this);
    address public immutable implementation;
    IERC6551Registry public immutable registry;
    uint256 public immutable chainId;

    /**
     * @dev Constructor to initialize the contract.
     * @param _implementation The address of the NFT implementation contract.
     * @param _registry The address of the ERC6551 registry contract.
     */
    constructor(
        address _implementation,
        address _registry       
    ) ERC721("EthOnlineNFT", "ETHO.NFT") {
        implementation = _implementation;
        registry = IERC6551Registry(_registry); 
    }

    /**
     * @dev Get the account associated with a given NFT token ID.
     * @param tokenId The ID of the NFT token.
     * @return The address of the associated account.
     */
    function getAccount(uint256 tokenId) public view returns (address) {
        return
            registry.account(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                0
            );
    }

    /**
     * @dev Create an account associated with a given NFT token ID.
     * @param tokenId The ID of the NFT token.
     * @return The address of the newly created account.
     */
    function createAccount(uint256 tokenId) public returns (address) {
        return
            registry.createAccount(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                0,
                ""
            );
    }

    /**
     * @dev Add Ether to an account associated with a given NFT token ID.
     * @param tokenId The ID of the NFT token.
     */
    function addEth(uint256 tokenId) external payable {
        address account = getAccount(tokenId);
        (bool success, ) = account.call{value: msg.value}("");
        require(success, "Failed to send ETH");
    }

    /**
     * @dev Mint a new NFT and assign it to the owner.
     * Only the owner of the contract can call this function.
     */
    function safeMint() public onlyOwner {
        _safeMint(msg.sender, ++totalSupply);
    }
}
