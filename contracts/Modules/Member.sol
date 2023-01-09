//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../interface/IERC20.sol";
import "../interface/IModules.sol";

contract MemberContract is IModules {
    modifier MemberCheck(address _daoAddr, address _memberAddr) {
        require(memberList[_daoAddr][_memberAddr].memberAddr != address(0), "Not Member");
        require(memberList[_daoAddr][_memberAddr].blacklist != 1, "Member in blacklist");
        _;
    }

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

    mapping(address => mapping(address => Member)) memberList;

    function updateMember_type(
        address _daoAddr,
        address _memberAddr,
        uint8 _type
    ) public AdminCheck(_daoAddr, msg.sender) MemberCheck(_daoAddr, _memberAddr) {
        memberList[_daoAddr][_memberAddr].memberType = _type;
    }

    function updateMember_contribution(
        address _daoAddr,
        address _memberAddr,
        uint256 _contribution
    ) public AdminCheck(_daoAddr, msg.sender) MemberCheck(_daoAddr, _memberAddr) {
        memberList[_daoAddr][_memberAddr].contribution = _contribution;
    }

    // function deleteMember(address _daoAddr, address _memberAddr) public AdminCheck(_daoAddr, msg.sender) MemberCheck(_daoAddr, _memberAddr){
    //     delete memberList[_daoAddr][_memberAddr];
    // }
    function memberBlacklist(
        address _daoAddr,
        address _memberAddr
    ) public AdminCheck(_daoAddr, msg.sender) MemberCheck(_daoAddr, _memberAddr) {
        memberList[_daoAddr][_memberAddr].blacklist = 1;
    }

    function memberJoin(address _daoAddr, address _memberAddr) public {
        require(memberList[_daoAddr][_memberAddr].memberAddr == address(0), "Member already exist");
        Member memory newMember = Member({ memberAddr: msg.sender, memberType: 1, blacklist: 0, contribution: 0 });
        memberList[_daoAddr][_memberAddr] = newMember;
        BaseDAO dao = BaseDAO(_daoAddr);
        dao.addMember(_memberAddr);
    }

    function memberQuit(address _daoAddr, address _memberAddr) public MemberCheck(_daoAddr, _memberAddr) {
        require(memberList[_daoAddr][_memberAddr].memberAddr == msg.sender, "Error Member");
        delete memberList[_daoAddr][_memberAddr];
        BaseDAO dao = BaseDAO(_daoAddr);
        dao.removeMember(_memberAddr);
    }
}
