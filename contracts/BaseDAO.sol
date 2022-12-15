// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.6;

import "./BaseToken.sol";
import "./airdrop/AirdropV2.sol";

contract BaseDAO {
    bool private initialized;
    uint256 public createTime; // dao 创建时间 0
    address public DAOToken;

    uint256 bank;
    BaseToken public token;
    // Airdrop public adMod;

    uint256 public proposalCount = 0;
    struct Proposal {
        address applicant; // 申请人
        string details; // 细节--可以进行加密
        uint256 startingPeriod; // 开始时间
    }

    mapping(address => bool) public administrator;
    mapping(uint256 => Proposal) public proposalList;
    mapping(uint256 => mapping(address => uint8)) public voters;
    mapping(uint256 => address[]) public allVoters;
    mapping(address => uint256) balance;
    mapping(address => bool) public tokenWhitelist;
    mapping(address => uint256) public tokenPrice_otherErc20;

    uint256 periodDuration; // 17280
    uint256 votingPeriodLength; // 35
    uint256 tokenPrice = 1;

    event eVote(uint256 pId);
    event transferEvent(uint256 amount, string t);
    event airdropRequest(address _recipients, address _tokenAddr, uint256 _values);
    // event airdropCreated(address addr);

    modifier Initialized() {
        require(initialized, "DAO is not initialized");
        _;
    }
    modifier OnlyAdmin(address addr) {
        require(administrator[addr] == true, "Not Administrator");
        _;
    }

    function _setConfig(address _tokenAddr, uint256 _periodDuration, uint256 _votingPeriodLength) internal {
        DAOToken = _tokenAddr;
        periodDuration = _periodDuration;
        votingPeriodLength = _votingPeriodLength;
    }

    function _setToken(string memory _name, string memory _symbol) internal {
        token = new BaseToken(_name, _symbol);
    }

    function setPrice(uint256 _price) public OnlyAdmin(msg.sender) {
        tokenPrice = _price;
    }

    function setPrice_otherErc20(address _tokenAddr, uint256 _price) public OnlyAdmin(msg.sender) {
        require(tokenWhitelist[_tokenAddr] == true, "Token already in White list");
        tokenPrice_otherErc20[_tokenAddr] = _price;
    }

    function init(
        address _admin,
        address _tokenAddr,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        string memory _name,
        string memory _symbol
    ) external {
        require(!initialized, "initialized");
        _setConfig(_tokenAddr, _periodDuration, _votingPeriodLength);
        _setToken(_name, _symbol);

        createTime = block.timestamp;
        initialized = true;
        administrator[_admin] = true;
        administrator[address(this)] = true;
    }

    function init_test_only() external {
        require(!initialized, "initialized");
        _setConfig(address(0), 17280, 35);
        _setToken("BaseTest", "BAT");

        createTime = block.timestamp;
        initialized = true;
        administrator[msg.sender] = true;
        administrator[address(this)] = true;
    }

    // =============================== PROPOSAL FUNCTION START =========================================
    function createProposal(address applicant, string memory details) public {
        // do something
        Proposal memory proposal = Proposal({
            applicant: applicant,
            details: details,
            startingPeriod: getCurrentPeriod() // 45
        });
        proposalList[proposalCount] = proposal;
        proposalCount += 1;
    }

    function processProposal() public {}

    function submitVote(uint256 pId, uint8 uintVote) public {
        address addr = msg.sender;
        // Proposal proposal = proposalList[proposalIndex];
        require(pId < proposalCount, "proposalIndex Error");
        require(uintVote == 1 || uintVote == 2, "uintVote Error");

        require(voters[pId][addr] == 0, "member already voted");

        require(getCurrentPeriod() - proposalList[pId].startingPeriod <= votingPeriodLength, "voting time passed");

        allVoters[pId].push(addr);

        if (uintVote == 1) {
            voters[pId][addr] = 1;
        } else if (uintVote == 2) {
            voters[pId][addr] = 2;
        }
        emit eVote(pId);
    }

    function getAllVoters(uint256 pId) public view returns (address[] memory) {
        return allVoters[pId];
    }

    function getCurrentPeriod() public view returns (uint256) {
        return (block.timestamp - createTime) / (periodDuration);
    }

    // =============================== PROPOSAL FUNCTION END =========================================

    function buy() public payable Initialized {
        // require(initialized, "!initialized");
        uint256 amountTobuy = msg.value * tokenPrice; // 设定价格
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit transferEvent(amountTobuy, "buy");
        // emit Bought(amountTobuy);
    }

    function buy_byOtherErc20(address _tokenAddr, uint256 _amount) public Initialized {
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

    function sell(uint256 _amount) public Initialized {
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

    function sell_byOtherErc20(uint256 _amount, address _tokenAddr) public Initialized {
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

    function addToWhitelist(address _tokenAddr, uint256 _price) public OnlyAdmin(msg.sender) {
        // require(administrator[msg.sender] == true, "only admin can do it");
        require(tokenWhitelist[_tokenAddr] == false, "Token already in White list");
        tokenWhitelist[_tokenAddr] = true;
        setPrice_otherErc20(_tokenAddr, _price);
    }

    // ========================== AIRDROP FUNCTION START ===============================
    // function setAirdrop() public OnlyAdmin(msg.sender) {
    //     adMod = new Airdrop();
    //     emit airdropCreated(address(adMod));
    // }

    // function AirTransferDiffValue_dao(
    //     address[] memory _recipients,
    //     uint256[] memory _values,
    //     address _tokenAddress
    // ) external {
    //     adMod.AirTransferDiffValue(_recipients, _values, _tokenAddress);
    // }
    // function airdropTransfer(address _airdoropAddr, address _recipients, address _tokenAddr, uint256 _values) public OnlyAdmin(msg.sender) {
    //     IERC20 otherToken = IERC20(_tokenAddr);
    //     otherToken.transfer(_airdoropAddr, _values);
    //     emit airdropRequest(_recipients, _tokenAddr, _values);
    // }
    // ========================== AIRDROP FUNCTION END =================================
}
