// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

// import "./BaseDAO.sol";
import "./interface/IBaseDAO.sol";

// import "./interface/IDAOFactory.sol";

// =========== DAO 完成后修改 ==============

contract CloneFactory {
    // implementation of eip-1167 - see https://eips.ethereum.org/EIPS/eip-1167
    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }
}

contract DAOFactory is CloneFactory {
    address public template;
    mapping(uint256 => address) public daos;
    uint256 public daoIdx = 0;

    // Moloch private moloch; // moloch contract

    constructor(address _template) {
        template = _template;
    }

    event CreateComplete(address indexed DaoAddr, address _admin);

    // ============= 根据DAO的init function 修改输入参数 ==============
    function createBaseDAO(address _admin) public returns (address) {
        BaseDAO baseDao = BaseDAO(createClone(template));

        baseDao.init(_admin);

        daoIdx = daoIdx + 1;
        daos[daoIdx] = address(baseDao);
        emit CreateComplete(address(baseDao), _admin);

        return address(baseDao);
        // return daos[daoIdx];
    }

    function returnTest() public view returns (address) {
        return template;
    }
}
