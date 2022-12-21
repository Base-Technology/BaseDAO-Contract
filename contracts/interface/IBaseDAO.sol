// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

contract IBaseDAO {
    bool private initialized;
    mapping(address => bool) public administrator;
    mapping(address => bool) public modules;
    mapping(address => bool) public tokenWhitelist;

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
}
