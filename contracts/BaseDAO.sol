// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interface/IBaseDAO.sol";

contract BaseDAO is IBaseDAO {
    // bool private initialized;

    // mapping(address => bool) public administrator;
    // mapping(address => bool) public modules;
    // mapping(address => bool) public tokenWhitelist;
    // mapping(address => bool) public members;
    event transferEvent(uint256 amount, string t);

    function adminCheck(address memberAddr) external view OnlyModules(msg.sender) returns (bool) {
        require(administrator[memberAddr] == true, "Not Administrator");
        return true;
    }

    // ============ 需要修改 admin的传入交由Factory来进行 ==============
    function init(address _admin) public override {
        require(!initialized, "initialized");
        initialized = true;
        administrator[_admin] = true;
        administrator[address(this)] = true;
    }

    function addModule(address _moduleAddr) external override OnlyAdmin(msg.sender) {
        require(_moduleAddr != address(0x0), "module address must not be empty");
        require(modules[_moduleAddr] == false, "module already in use");
        modules[_moduleAddr] = true;
    }

    function removeModule(address _moduleAddr) external override OnlyAdmin(msg.sender) {
        require(_moduleAddr != address(0x0), "module address must not be empty");
        require(modules[_moduleAddr] == true, "module already delete");
        delete modules[_moduleAddr];
    }

    function addMember(address _memberAddr) external override AdminOrModules(msg.sender) {
        require(_memberAddr != address(0x0), "member address must not be empty");
        require(members[_memberAddr] == false, "member already in use");
        members[_memberAddr] = true;
    }

    function removeMember(address _memberAddr) external override AdminOrModules(msg.sender) {
        require(_memberAddr != address(0x0), "member address must not be empty");
        require(members[_memberAddr] == true, "member already delete");
        delete members[_memberAddr];
    }

    function addTokeWL(address _tokenAddr) external override AdminOrModules(msg.sender) {
        require(_tokenAddr != address(0x0), "token address must not be empty");
        require(tokenWhitelist[_tokenAddr] == false, "token already in use");
        tokenWhitelist[_tokenAddr] = true;
    }

    function removeTokenWL(address _tokenAddr) external override AdminOrModules(msg.sender) {
        require(_tokenAddr != address(0x0), "token address must not be empty");
        require(tokenWhitelist[_tokenAddr] == true, "token already delete");
        delete tokenWhitelist[_tokenAddr];
    }

    function withdrawalToken(address _tokenAddress) external override OnlyAdmin(msg.sender) {
        ERC20 airdrop_token = ERC20(_tokenAddress);
        airdrop_token.transfer(msg.sender, airdrop_token.balanceOf(address(this)));
    }

    function rechargeToken(address _tokenAddr, uint256 _amount) external override {
        ERC20 otherToken = ERC20(_tokenAddr);
        uint256 allowance = otherToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        otherToken.transferFrom(msg.sender, address(this), _amount);
    }

    // ============== erc20 ===================
    function sendERC20(
        address _targetAddr,
        address _tokenAddr,
        uint256 _amount
    ) external override AdminOrModules(msg.sender) {
        require(_amount > 0, "You need to send some ether");
        ERC20 token = ERC20(_tokenAddr);
        uint256 dexBalance = token.balanceOf(address(this));
        require(_amount <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(_targetAddr, _amount);
        emit transferEvent(_amount, "send");
    }

    function receiveERC20(address _tokenAddr, uint256 _amount) external override {
        require(_amount > 0, "You need to send at least some tokens");
        ERC20 token = ERC20(_tokenAddr);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        emit transferEvent(_amount, "receive");
    }

    function sendGasToken(address _targetAddr, uint256 _amount) external OnlyAdmin(msg.sender) {
        payable(_targetAddr).transfer(_amount);
    }

    function receiveGasToken() external payable {
        emit transferEvent(msg.value, "receive");
    }
    // function createToken
}
