// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasedCatsTest is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 public maxSupply;
    uint256 public maxWlSupply;
    uint256 public maxPubSupply;
    uint256 public wlMintPrice;
    uint256 public pubMintPrice;
    bool public publicMintOpen;
    bool public allowListMintOpen;
    mapping(address => bool) public allowList;
    mapping(address => uint256) public pubAdd;

    constructor()
        ERC721("Test", "TT")
        Ownable(0x5911b17fdC574943a6Fd2777EE9969532e00CaC3)
    {
        maxSupply = 51;
        publicMintOpen = false;
        allowListMintOpen = false;
        maxWlSupply = 3;
        maxPubSupply = 5;
        wlMintPrice = 0.0001 ether;
        pubMintPrice = 0.0005 ether;
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://ipfs.io/ipfs/bafybeife2iqs5xgtcbrqb7bvzoljso5p7zd45wfu7nimcjefvktdtknkdi/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdrawlFunds() external onlyOwner {
        // Get the balance of the contract
        uint256 balance = address(this).balance;

        // Transfer the balance to the owner's address
        payable(owner()).transfer(balance);
    }

    //Modify public mint and allowlist mint open
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //Require Only Allowlist To Mint
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    //Allowlist Mint
    function allowlistMint(uint256 quantity_) public payable {
        require(allowListMintOpen, "Whitelist Mint Closed");
        require(allowList[msg.sender], "You are not in the Allow List");
        require(msg.value == quantity_ * wlMintPrice, "Not Enough Funds");
        require(totalSupply() + quantity_ < 100, "Sold Out");
        require(
            allowList[msg.sender] && quantity_ <= maxWlSupply,
            "Exceed Max Wallet!"
        );
        internalMint(quantity_);
    }

    //PublicMint
    function publicMint(uint256 quantity_) public payable {
        require(publicMintOpen, "Public Mint Closed");
        require(msg.value == quantity_ * pubMintPrice, "Not Enough Funds");
        require(totalSupply() + quantity_ < maxSupply, "No more supply left");
        require(
            pubAdd[msg.sender] + quantity_ <= maxPubSupply,
            "Exceed Max Wallet!"
        );
        internalMint(quantity_);
    }

    function internalMint(uint256 quantity_) internal {
        for (uint256 i = 0; i < quantity_; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
