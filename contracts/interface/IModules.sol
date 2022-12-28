// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "../interface/IBaseDAO.sol";

interface IModules {
    // modifier AdminCheck(address _daoAddr, address _memberAddr) {
    //     IBaseDAO dao = IBaseDAO(_daoAddr);
    //     require(dao.adminCheck(_memberAddr) == true, "Not Administrator");
    //     _;
    // }
    // modifier ModulesCheck(address _daoAddr) {
    //     IBaseDAO dao = IBaseDAO(_daoAddr);
    //     require(dao.modules[address(this)] == true, "Module has no permission");
    //     _;
    // }
}
