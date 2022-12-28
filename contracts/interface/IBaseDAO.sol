// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IBaseDAO {
    function adminCheck(address memberAddr) external returns (bool);

    function addMember(address _memberAddr) external;

    function removeMember(address _memberAddr) external;
}
