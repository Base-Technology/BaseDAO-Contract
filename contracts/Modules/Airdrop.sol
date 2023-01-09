//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../interface/IERC20.sol";
import "../interface/IModules.sol";
import "../interface/IBaseDAO.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "../BaseDAO.sol";

contract AirdropContract is IModules {
    function AirTransferDiffValue(
        address[] memory _recipients,
        uint256[] memory _values,
        address _daoAddr,
        address _tokenAddress
    ) public AdminCheck(_daoAddr, msg.sender) returns (bool) {
        require(_recipients.length > 0);
        require(_recipients.length == _values.length);

        // IERC20 token = IERC20(_tokenAddress);
        IBaseDAO baseDAO = IBaseDAO(_daoAddr);

        for (uint j = 0; j < _recipients.length; j++) {
            // token.transferFrom(_daoAddr, _recipients[j], _values[j]);
            baseDAO.sendERC20(_recipients[j], _tokenAddress, _values[j]);
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
        // IERC20 token = IERC20(_tokenAddress);
        IBaseDAO baseDAO = IBaseDAO(_daoAddr);
        for (uint j = 0; j < _recipients.length; j++) {
            // token.transferFrom(_daoAddr, _recipients[j], _value);
            baseDAO.sendERC20(_recipients[j], _tokenAddress, _value);
        }
        return true;
    }

    function withdrawalToken(address _daoAddr, address _tokenAddress) public AdminCheck(_daoAddr, msg.sender) {
        IERC20 token = IERC20(_tokenAddress);
        // token.transfer(_daoAddr, token.balanceOf(address(this)));
        IBaseDAO baseDAO = IBaseDAO(_daoAddr);
        baseDAO.sendERC20(msg.sender, _tokenAddress, token.balanceOf(_daoAddr));
    }
}
