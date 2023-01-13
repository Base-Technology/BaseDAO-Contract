//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IModules.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

contract ERC20Mod is ERC20VotesUpgradeable, IModules {

    function initialize() public initializer {
      __ERC20Votes_init();
    }

    function mint(address _daoAddr, address account, uint256 amount) public AdminCheck(_daoAddr, msg.sender) {
        _mint(account, amount);
    }

    function burn(address _daoAddr, address account, uint256 amount) public AdminCheck(_daoAddr, msg.sender) {
        _burn(account, amount);
    }
}