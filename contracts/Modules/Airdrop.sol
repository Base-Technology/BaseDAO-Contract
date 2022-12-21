//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interface/IERC20.sol";
import "../interface/IModules.sol";

contract AirdropContract is IModules {
    function AirTransferDiffValue(
        address[] memory _recipients,
        uint256[] memory _values,
        address _daoAddr,
        address _tokenAddress
    ) public AdminCheck(_daoAddr, msg.sender) returns (bool) {
        require(_recipients.length > 0);
        require(_recipients.length == _values.length);

        IERC20 token = IERC20(_tokenAddress);

        for (uint j = 0; j < _recipients.length; j++) {
            token.transferFrom(_daoAddr, _recipients[j], _values[j]);
        }

        return true;
    }

    function AirTransfer(
        address[] memory _recipients,
        uint256 _value,
        address _daoAddr,
        address _tokenAddress
    ) public AdminCheck(_daoAddr, msg.sender) returns (bool) {
        require(_recipients.length > 0);
        IERC20 token = IERC20(_tokenAddress);
        for (uint j = 0; j < _recipients.length; j++) {
            token.transferFrom(_daoAddr, _recipients[j], _value);
        }
        return true;
    }

    function withdrawalToken(address _daoAddr, address _tokenAddress) public AdminCheck(_daoAddr, msg.sender) {
        IERC20 token = IERC20(_tokenAddress);
        token.transferFrom(_daoAddr, token.balanceOf(address(this)));
    }
}
