// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;
import "solmate/tokens/ERC721.sol";

error IndexOutOfBounds();

/// @notice Enumerable extension for Solmate ERC-721 implementation.
abstract contract ERC721Enumerable is ERC721 {

    /*///////////////////////////////////////////////////////////////
                          ENUMERABLE STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    /*///////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
        return 
            interfaceId == 0x780e9d63 || // ERC165 Interface tokenId for ERC721Enumerable
            super.supportsInterface(interfaceId);
    }

    /*///////////////////////////////////////////////////////////////
                         ERC721 ENUMERABLE INTERFACE
    //////////////////////////////////////////////////////////////*/

    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) external view returns (uint256) {
        if (index >= this.totalSupply()) {
            revert IndexOutOfBounds();
        }
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        if (index >= this.balanceOf(owner)) {
            revert IndexOutOfBounds();
        }
        return _ownedTokens[owner][index];
    }

    /*///////////////////////////////////////////////////////////////
                         ERC721 EXTENDED LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        _beforeTransfer(from, to, tokenId);
        super.transferFrom(from, to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        _beforeTransfer(address(0), to, tokenId);
        super._mint(to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        _beforeTransfer(this.ownerOf(tokenId), address(0), tokenId);
        super._burn(tokenId);
    }

    function _beforeTransfer(address from, address to, uint256 tokenId) internal virtual {
        if (from == address(0)) {
            _addToAllTokens(tokenId);
        } else if (from != to) {
            _removeFromOwnerTokens(from, tokenId);
        }
        if (to == address(0)) {
            _removeFromAllTokens(tokenId);
        } else if (to != from) {
            _addToOwnerTokens(to, tokenId);
        }
    }

    function _addToOwnerTokens(address to, uint256 tokenId) private {
        uint256 length = this.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addToAllTokens(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeFromOwnerTokens(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = this.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _allTokens[lastTokenIndex];

            _ownedTokens[from][tokenIndex] = _ownedTokens[from][lastTokenIndex];
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeFromAllTokens(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
