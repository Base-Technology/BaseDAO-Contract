//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IERC20.sol";
import "../interface/IModules.sol";

contract ERC721Mod is IModules {
    modifier AdminCheck(address _daoAddr, address _memberAddr) {
        IBaseDAO dao = IBaseDAO(_daoAddr);
        require(dao.adminCheck(_memberAddr) == true, "Not Administrator");
        _;
    }
}
