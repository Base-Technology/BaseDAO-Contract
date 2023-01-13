//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IModules.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract ERC721Mod is ERC721EnumerableUpgradeable, IERC721Receiver, IModules {

    function initialize(string memory name_, string memory symbol_) public initializer {
      __ERC721_init(name_, symbol_);
    }

    function safeMint(address _daoAddr, address to, uint256 tokenId) public AdminCheck(_daoAddr, msg.sender) {
        _safeMint(to, tokenId);
    }

    function burn(address _daoAddr, uint256 tokenId) public AdminCheck(_daoAddr, msg.sender) {
        _burn(tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}