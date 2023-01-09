// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
// import "../interface/IBaseDAO.sol";
import "../BaseDAO.sol";

abstract contract IBaseDAO {
    constructor() {}

    bool public initialized;

    mapping(address => bool) public administrator;
    mapping(address => bool) public modules;
    mapping(address => bool) public tokenWhitelist;
    mapping(address => bool) public members;

    modifier Initialized() {
        require(initialized, "DAO is not initialized");
        _;
    }
    modifier OnlyAdmin(address addr) {
        require(administrator[addr] == true, "Not Administrator");
        _;
    }
    modifier OnlyModules(address addr) {
        require(modules[addr] == true, "Module has no permission");
        _;
    }
    modifier AdminOrModules(address addr) {
        require(modules[addr] == true || administrator[addr] == true, "admin or modules");
        _;
    }

    function init(address _admin) public virtual;

    function addModule(address _moduleAddr) external virtual;

    function removeModule(address _moduleAddr) external virtual;

    function addMember(address _memberAddr) external virtual;

    function removeMember(address _memberAddr) external virtual;

    function addTokeWL(address _tokenAddr) external virtual;

    function removeTokenWL(address _tokenAddr) external virtual;

    function withdrawalToken(address _tokenAddress) external virtual;

    function rechargeToken(address _tokenAddr, uint256 _amount) external virtual;

    function sendERC20(address _targetAddr, address _tokenAddr, uint256 _amount) external virtual;

    function receiveERC20(address _tokenAddr, uint256 _amount) external virtual;
}
