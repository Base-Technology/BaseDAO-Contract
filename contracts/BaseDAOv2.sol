// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.6;

import "./interface/IBaseDAO.sol";
import "./interface/IERC20.sol";

contract BaseDAO is IBaseDAO {
    function init() external {
        require(!initialized, "initialized");
        initialized = true;
        administrator[msg.sender] = true;
        administrator[address(this)] = true;
    }

    function addModule(address _moduleAddr) external {
        require(_moduleAddr != address(0x0), "module address must not be empty");
        require(modules[_moduleAddr] == false, "module already in use");
        modules[_moduleAddr] == true;
    }

    function removeModule(address _moduleAddr) external {
        require(_moduleAddr != address(0x0), "module address must not be empty");
        require(modules[_moduleAddr] == true, "module already in use");
        delete modules[_moduleAddr];
    }

    function withdrawalToken(address _tokenAddress) public OnlyAdmin(msg.sender) {
        IERC20 airdrop_token = IERC20(_tokenAddress);
        airdrop_token.transfer(owner, token.balanceOf(address(this)));
    }

    function rechargeToken(address _tokenAddr, uint256 _amount) public {
        IERC20 otherToken = IERC20(_tokenAddr);
        uint256 allowance = otherToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        otherToken.transferFrom(msg.sender, address(this), _amount);
    }
}
