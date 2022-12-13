// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma abicoder v2;

interface IDAOFactory {
    function createBaseDAO(address, address, uint256, uint256, string memory, string memory) external returns (address);
}
