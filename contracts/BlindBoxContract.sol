// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;
import "./IBlindBox.sol";

contract BlindBoxContract is IBlindBox {
    address public root;
    address public dealer;
    address public player;
    BlindBoxState private state;
    uint8 public luckyCount;
    uint256 private blindHash;
    uint256 private betHash;

    constructor(
        address _dealer,
        uint8 _luckyCount
    ) {
        root = msg.sender;
        dealer = _dealer;
        luckyCount = _luckyCount;
        state = BlindBoxState.lottered;
    }

    modifier onlyRoot() {
        require(msg.sender == root, "Only root can call this.");
        _;
    }

    modifier onlyDealer() {
        require(msg.sender == dealer, "Only dealer can call this.");
        _;
    }

    function getState() public view override returns (BlindBoxState) {
        return state;
    }

    function getBlindHash() public view override returns (uint256) {
        return blindHash;
    }

    function getBetHash() public view override returns (uint256) {
        return betHash;
    }

    //扪盒
    function foldBlindBox(uint256 _hash) public override onlyRoot {
        require(state == BlindBoxState.lottered, "xx");
        state = BlindBoxState.folding;
        blindHash = _hash;
        betHash = 0;
    }

    //下注
    function placeBet(
        uint8 _luckyNumber,
        string memory _nonce
    ) public payable returns (uint256) {
        require(state == BlindBoxState.folding, "cannot be bet");
        uint256 betAmount = address(this).balance / luckyCount;
        require(
            betAmount <= gasleft() * 10,
            "The bet amount cannot be less than 10 times the gas fee"
        );
        state = BlindBoxState.betting;
        uint256 balance = address(this).balance + msg.value;
        payable(address(this)).transfer(balance);
        betHash = genHash(_luckyNumber, _nonce);
        player = msg.sender;
        state = BlindBoxState.beted;
        return betHash;
    }

    //开盒
    function lottery(
        uint8 _luckyNumber,
        string memory _nonce
    ) public override onlyRoot returns (bool) {
        require(state == BlindBoxState.beted, "xxx");
        state = BlindBoxState.lottering;
        bool win = isWin(_luckyNumber, _nonce);
        LotteryMessage memory lm = LotteryMessage(
            player,
            win,
            betHash,
            blindHash,
            block.timestamp
        );
        emit LotteryEvent(lm);
        splitBonus();
        state = BlindBoxState.lottered;
        return win;
    }

    function splitBonus() private {
        uint8 odds = 20;
        uint8 brokerageRate = 70;
        uint8 taxRate = 30;
        uint256 bonus = (address(this).balance * 80) / 100;
        uint256 kickback = (bonus * odds) / 100;
        uint256 income = bonus - kickback;
        uint256 brokerage = (kickback * brokerageRate) / 100;
        uint256 tax = kickback - brokerage;

        payable(player).transfer(income);
        payable(dealer).transfer(brokerage);
        payable(root).transfer(tax);

        SplitMessage memory sm = SplitMessage(
            player,
            dealer,
            root,
            odds,
            brokerageRate,
            taxRate,
            address(this).balance,
            bonus,
            brokerage,
            tax,
            income,
            block.timestamp
        );
        emit SplitEvent(sm);
    }

    fallback() external payable {
        BetMessage memory bm = BetMessage(
            player,
            0,
            betHash,
            msg.value,
            address(this).balance,
            block.timestamp
        );

        emit BetEvent(bm);
    }

    receive() external payable {
        BetMessage memory bm = BetMessage(
            player,
            1,
            betHash,
            msg.value,
            address(this).balance,
            block.timestamp
        );

        emit BetEvent(bm);
    }

    function getBalance() public view override returns (uint256) {
        return address(this).balance;
    }

    function isWin(
        uint8 _luckyNumber,
        string memory _nonce
    ) public view override returns (bool) {
        require(state == BlindBoxState.lottering, "xxx");
        uint256 bh = genHash(_luckyNumber, _nonce);
        return bh == betHash;
    }

    function genHash(
        uint8 _luckyNumber,
        string memory _nonce
    ) public pure override returns (uint256) {
        bytes32 packed = keccak256(abi.encodePacked(_luckyNumber, _nonce));
        return uint256(packed);
    }

    function compareHash(
        uint8 _luckyNumber,
        string memory _nonce,
        uint256 _toHash
    ) public pure override returns (bool) {
        return genHash(_luckyNumber, _nonce) == _toHash;
    }
}
