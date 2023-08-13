// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;
import "./IBlindBox.sol";
import "./SafeMath.sol";

/**
 * Blind box game gameplay: Players only need to guess a lucky number.
 * If they win, they will receive a certain proportion of the current prize pool's bonus.
 * If they lose, the bet money will be included in the prize pool.
 * The operator can apply for blind boxes from the platform, and can apply for multiple blind boxes.
 * The operator can receive a certain proportion of the transaction fee from the player's winning.
 *
 * Security: The blind box platform is betting a lucky number and generating a hash.
 * After the lottery, players and operators can verify that the platform has not cheated by verifying the hash. Similarly,
 * players will also generate a hash of the guessed lucky number after placing a bet,
 * so It is fair and transparent to platforms, operators, and players.
 */
contract BlindBoxContract is IBlindBox {
    using SafeMath for *;
    address private root;
    address private dealer;
    address private player;
    address private deployer;
    BlindBoxState private state;
    bool private running;
    uint8 public luckyCount; //account of lucky numbers
    uint256 private blindHash; //Hash of blindbox
    uint256 private betHash; //Hash of player bet
    uint16 public odds = 80; //Winning Pool odds
    uint16 public kickbackRate = 20; //kickback rate
    uint16 public brokerageRate = 70; //Operator commission rate, which is the proportion of kickback rate
    uint16 public taxRate = 30; //Platform tax rate, which is the proportion of handling fees

    constructor(address _root, address _dealer, uint8 _luckyCount) {
        deployer = msg.sender;
        root = _root;
        dealer = _dealer;
        luckyCount = _luckyCount;
        state = BlindBoxState.lottered;
        running = true;
    }

    modifier onlyRoot() {
        require(msg.sender == root, "Only root can call this.");
        _;
    }

    modifier onlyDealer() {
        require(msg.sender == dealer, "Only dealer can call this.");
        _;
    }
    modifier onlyPlayer() {
        require(msg.sender == player, "Not a betting player");
        _;
    }

    function getState() public view override returns (BlindBoxState) {
        return state;
    }

    function getRoot() public view override returns (address) {
        return root;
    }

    function getDealer() public view override returns (address) {
        return dealer;
    }

    function getPlayer() public view override returns (address) {
        return player;
    }

    function isRunning() public view override returns (bool) {
        return running;
    }

    function stop() public override onlyDealer {
        running = false;
    }

    function run() public override onlyDealer {
        running = true;
    }

    function getBlindHash() public view override returns (uint256) {
        return blindHash;
    }

    function getBetHash() public view override returns (uint256) {
        return betHash;
    }

    function getBetFunds() public view override returns (uint256) {
        uint256 funds = (address(this).balance).div(luckyCount);
        return funds;
    }

    function getBonus() public view override returns (uint256) {
        uint256 bonus = (address(this).balance).mul(odds).div(100);
        return bonus;
    }

    function getKickbackFunds() public view override returns (uint256) {
        uint256 bonus = getBonus();
        uint256 kickback = bonus.mul(kickbackRate).div(100);
        return kickback;
    }

    function getBrokerageFunds() public view override returns (uint256) {
        uint256 kickback = getKickbackFunds();
        uint256 brokerage = kickback.mul(brokerageRate).div(100);
        return brokerage;
    }

    ///@dev Divided revenue from the platform's handling fees after the lottery
    function getTaxFunds() public view override returns (uint256) {
        uint256 tax = getKickbackFunds() - getBrokerageFunds();
        return tax;
    }

    ///@dev The actual income that players can enjoy after winning, excluding gas fees
    function getIncome() public view override returns (uint256) {
        uint256 bonus = getBonus();
        uint256 kickback = getKickbackFunds();
        uint256 income = bonus - kickback;
        return income;
    }

    ///@dev The rate of return that players can enjoy after winning
    function getBenefitRate() public view override returns (uint16) {
        uint16 benefitRate = uint16(
            (odds.mul(100.sub(kickbackRate)).div(100)).mul(luckyCount)
        );
        return benefitRate;
    }

    function setOdds(uint16 _odds) public override onlyDealer {
        require(
            state == BlindBoxState.folding,
            "Can only be changed when folding"
        );
        odds = _odds;
    }

    function setKickbackRate(uint16 _kickbackRate) public override onlyDealer {
        require(
            state == BlindBoxState.folding,
            "Can only be changed when folding"
        );
        kickbackRate = _kickbackRate;
    }

    function setKickbackAllocationRatio(
        uint16 _brokerageRate,
        uint16 _taxRate
    ) public override onlyDealer {
        require(
            state == BlindBoxState.folding,
            "Can only be changed when folding"
        );
        require(
            _brokerageRate + _taxRate == 1,
            "BrokerageRate plus TaxRate must be equal to 1"
        );
        brokerageRate = _brokerageRate;
        taxRate = _taxRate;
    }

    ///@dev Touchbox, the platform will bet on the lucky number and generate a hash. After the lottery, anyone can verify it through the publicly available hash algorithm in the contract
    function foldBlindBox(uint256 _hash) public override onlyRoot {
        require(running, "Blind box has stopped");
        require(
            state == BlindBoxState.lottered,
            "Must have won a prize before calling"
        );
        blindHash = _hash;
        betHash = 0;
        state = BlindBoxState.folding;
    }

    ///@dev Betting, players must make payment to the contract through wallet before calling this method
    function placeBet(
        uint8 _luckyNumber,
        string memory _nonce
    ) public onlyPlayer returns (uint256) {
        require(running, "Blind box has stopped");
        require(state == BlindBoxState.betting, "Bet not paid");

        betHash = genHash(_luckyNumber, _nonce);
        state = BlindBoxState.beted;
        return betHash;
    }

    ///@dev Open the box or draw a prize. This method only allows platform calls
    function lottery(
        uint8 _luckyNumber,
        string memory _nonce
    ) public override onlyRoot returns (bool) {
        require(running, "Blind box has stopped");
        require(state == BlindBoxState.beted, "Bet not completed");
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
        player = address(0x0);
        state = BlindBoxState.lottered;
        return win;
    }

    function splitBonus() private {
        uint256 betFunds = getBetFunds();
        uint256 bonus = getBonus();
        uint256 kickback = getKickbackFunds();
        uint256 brokerage = getBrokerageFunds();
        uint256 tax = getTaxFunds();
        uint256 income = getIncome();

        (bool success, ) = payable(player).call{value: income}(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
        (bool success1, ) = payable(dealer).call{value: brokerage}(
            new bytes(0)
        );
        require(success1, "ETH_TRANSFER_FAILED");
        (bool success2, ) = payable(root).call{value: tax}(new bytes(0));
        require(success2, "ETH_TRANSFER_FAILED");

        SplitMessage memory sm = SplitMessage(
            player,
            dealer,
            root,
            odds,
            kickbackRate,
            brokerageRate,
            taxRate,
            address(this).balance,
            betFunds,
            bonus,
            kickback,
            brokerage,
            tax,
            income,
            block.timestamp
        );
        emit SplitEvent(sm);
    }

    function feed() external payable {
        require(msg.value > 0, "Feeding cannot be zero");
        uint256 prevBalance = (address(this).balance - msg.value);
        BetMessage memory bm = BetMessage(
            msg.sender,
            2, //2 represents feeding
            betHash,
            msg.value,
            address(this).balance,
            prevBalance,
            gasleft()
        );
        emit BetEvent(bm);
    }

    fallback() external payable {
        require(false, "No other calls supported");
    }

    receive() external payable {
        require(running, "Blind box has stopped");
        uint256 prevBetFunds = (address(this).balance - msg.value).div(
            luckyCount
        );

        require(state == BlindBoxState.folding, "cannot be bet");
        require(
            msg.value >= prevBetFunds,
            string(
                abi.encodePacked(
                    "The betting amount should be at least ",
                    msg.value
                )
            )
        );
        state = BlindBoxState.betting;
        player = msg.sender;
        BetMessage memory bm = BetMessage(
            msg.sender,
            1, //1 represents a transaction
            betHash,
            msg.value,
            address(this).balance,
            prevBetFunds,
            gasleft()
        );

        emit BetEvent(bm);
    }

    function getBalance() public view override returns (uint256) {
        return address(this).balance;
    }

    ///@dev Win or not
    function isWin(
        uint8 _luckyNumber,
        string memory _nonce
    ) public view override returns (bool) {
        require(state == BlindBoxState.lottering, "xxx");
        uint256 bh = genHash(_luckyNumber, _nonce);
        return bh == betHash;
    }

    ///@dev Generate Hash
    function genHash(
        uint8 _luckyNumber,
        string memory _nonce
    ) public pure override returns (uint256) {
        bytes32 packed = keccak256(abi.encodePacked(_luckyNumber, _nonce));
        return uint256(packed);
    }

    ///@dev Compare Hash
    function compareHash(
        uint8 _luckyNumber,
        string memory _nonce,
        uint256 _toHash
    ) public pure override returns (bool) {
        return genHash(_luckyNumber, _nonce) == _toHash;
    }
}
