//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interface/IERC20.sol";
import "../interface/IModules.sol";

contract MemberContract is IModules {
    struct Member {
        address memberAddr;
        uint8 memberType; // 成员等级 0-非成员/ 1-普通成员/ 2-核心成员/
        uint8 blacklist; // 是否被加入黑名单 0-否/ 1-是/
        uint256 contribution; // 成员贡献度
    }
    // 贡献度规则 0.0.1
    // 成员发布提案 -通过++ -失败+
    // admin自主设置
    // 投票+
    // recharge & buy ++
    // sell --

    mapping(address => mapping(address => Member)) members;

    function updateMember(address _daoAddr, Member _memberInfo) public AdminCheck(_daoAddr, msg.sneder) {}
}
