// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
// import "../interface/IBaseDAO.sol";
import "../BaseDAO.sol";

contract IModules {
    modifier AdminCheck(address _daoAddr, address _memberAddr) {
        BaseDAO dao = BaseDAO(_daoAddr);
        require(dao.administrator(_memberAddr) == true, "Not Administrator");
        _;
    }
    modifier ModulesCheck(address _daoAddr) {
        BaseDAO dao = BaseDAO(_daoAddr);
        require(dao.modules(address(this)) == true, "Module has no permission");
        _;
    }
}
