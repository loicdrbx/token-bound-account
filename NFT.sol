// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/interfaces/IERC6551Registry.sol";
import "https://github.com/erc6551/reference/blob/v0.2.0-deployment/src/lib/ERC6551AccountLib.sol";

contract NFT is ERC721, Ownable {

    // State variables
    uint256 public totalSupply;
    address public immutable tokenContract = address(this);
    address public immutable implementation;
    IERC6551Registry public immutable registry;
    uint256 public immutable chainId;

    constructor(
        address _implementation,
        address _registry       
    ) ERC721("EthOnlineNFT", "ETHO.NFT") {
        implementation = _implementation;
        registry = IERC6551Registry(_registry); 
    }

    function getAccount(uint256 tokenId) public view returns (address) {
        // Fill the implementation here
    }

    function createAccount(uint256 tokenId) public returns (address) {
        // Fill the implementation here
    }

    function addEth(uint256 tokenId) external payable {
        // Fill the implementation here
    }

    function safeMint() public onlyOwner {
        _safeMint(msg.sender, ++totalSupply);
    }
}
