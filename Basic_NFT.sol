// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC721, Pausable, AccessControl {
    using Counters for Counters.Counter;
    using Strings for uint256;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    Counters.Counter private _tokenIdCounter;

    string public baseURI;
    string public baseExtension;

    bool isRevealed;
    string noRevealedURI;


    constructor() ERC721("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function setBaseuri(string memory _baseURI) external onlyRole(UPGRADER_ROLE) {
        baseURI = _baseURI;
    }

    function setBaseExtension(string memory _baseExtension) external onlyRole(UPGRADER_ROLE) {
        baseExtension = _baseExtension;
    }

    function setNoRevealedURI(string memory _setNoRevealedURI) external onlyRole(UPGRADER_ROLE) {
        noRevealedURI = _setNoRevealedURI;
    }

    function revealedNFTURI() public onlyRole(UPGRADER_ROLE) {
        require(!isRevealed,"revealed alreay");
        isRevealed = true;
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        if(isRevealed){
            require(
                _exists(tokenId),
                "ERC721Metadata: URI query for nonexistent token"
            );
            return  string(abi.encodePacked(baseURI,tokenId.toString(),baseExtension));
        }else {
            return noRevealedURI;
        }

    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
