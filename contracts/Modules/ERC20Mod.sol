//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/IModules.sol";
import "../BaseToken.sol";

// ================== 需要修改 ====================

contract ERC20Mod is IModules {
    mapping(address => mapping(address => uint256)) tokenPrice;
    mapping(address => mapping(address => bool)) tokneWhitelist;

    modifier AdminCheck(address _daoAddr, address _memberAddr) {
        IBaseDAO dao = IBaseDAO(_daoAddr);
        require(dao.adminCheck(_memberAddr) == true, "Not Administrator");
        _;
    }

    function buy() public payable {
        // require(initialized, "!initialized");
        uint256 amountTobuy = msg.value * tokenPrice; // 设定价格
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit transferEvent(amountTobuy, "buy");
        // emit Bought(amountTobuy);
    }

    function buy_byOtherErc20(address _tokenAddr, uint256 _amount) public {
        // require(initialized, "!initialized");
        require(tokenWhitelist[_tokenAddr] == true, "You need to add this token to white list");
        uint256 amountTobuy = _amount * tokenPrice_otherErc20[_tokenAddr]; // 设定价格
        IERC20 otherToken = IERC20(_tokenAddr);

        uint256 buyerBalance = otherToken.balanceOf(msg.sender);
        require(buyerBalance >= _amount, "buyer balance check");

        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some token");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");

        uint256 allowance = otherToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");

        otherToken.transferFrom(msg.sender, address(this), _amount);
        token.transfer(msg.sender, amountTobuy);
        emit transferEvent(amountTobuy, "buy-otherToken");
        // emit Bought(amountTobuy);
    }

    function sell(uint256 _amount) public {
        // require(initialized, "!initialized");
        require(_amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        uint256 amountToSell = _amount * tokenPrice;
        payable(msg.sender).transfer(amountToSell);
        emit transferEvent(amountToSell, "sell");
        // 增加其他token的购买通道
        // emit Sold(amount);
    }

    function sell_byOtherErc20(uint256 _amount, address _tokenAddr) public {
        // require(initialized, "!initialized");
        require(_amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        // 接下来将合约中的token转移到账户里
        // payable(msg.sender).transfer(_amount);
        uint256 amountToSell = _amount * tokenPrice_otherErc20[_tokenAddr];
        IERC20 otherToken = IERC20(_tokenAddr);
        // uint256 allowance_sell = otherToken.allowance(address(this), msg.sender);
        // if(allowance_sell <= amountToSell){
        //     otherToken.approve(msg.sender, amountToSell);
        // }
        otherToken.transfer(msg.sender, amountToSell);
        emit transferEvent(amountToSell, "sell_byOtherToken");
        // emit Sold(amount);
    }

    function addToWhitelist(
        address _daoAddr,
        address _tokenAddr,
        uint256 _price
    ) public AdminCheck(_daoAddr, msg.sender) {
        // require(administrator[msg.sender] == true, "only admin can do it");
        require(tokenWhitelist[_tokenAddr] == false, "Token already in White list");
        require(_price != 0, "price equial 0");
        tokenWhitelist[_tokenAddr] = true;
        setPrice_otherErc20(_tokenAddr, _price);
    }
}
