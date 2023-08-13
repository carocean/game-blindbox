// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

interface IBlindBox {
    function getState() external returns (BlindBoxState);

    function getRoot() external returns (address);

    function getDealer() external returns (address);

    function getPlayer() external returns (address);

    function getBlindHash() external returns (uint256);

    function getBetHash() external returns (uint256);

    function getBetFunds() external returns (uint256);

    function getBonus() external returns (uint256);

    function getKickbackFunds() external returns (uint256);

    function getBrokerageFunds() external returns (uint256);

    function getTaxFunds() external returns (uint256);

    function getIncome() external returns (uint256);

    function getBenefitRate() external returns (uint16);

    function setOdds(uint16 odds) external;

    function setKickbackRate(uint16 kickbackRate) external;

    function setKickbackAllocationRatio(
        uint16 brokerageRate,
        uint16 taxRate
    ) external;

    function foldBlindBox(uint256 _hash) external;

    function placeBet(
        uint8 luckyNumber,
        string memory nonce
    ) external returns (uint256);

    function lottery(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (bool);

    function isWin(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (bool);

    function genHash(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (uint256);

    function compareHash(
        uint8 _luckyNumber,
        string memory _nonce,
        uint256 _toHash
    ) external returns (bool);

    function getBalance() external returns (uint256);

    event BetEvent(BetMessage _message);
    event LotteryEvent(LotteryMessage _message);
    event SplitEvent(SplitMessage _message);
}

enum BlindBoxState {
    folding,
    betting,
    beted,
    lottering,
    lottered
}

struct SplitMessage {
    address player;
    address dealer;
    address root;
    uint16 odds;
    uint16 kickbackRate;
    uint16 brokerageRate;
    uint16 taxRate;
    uint256 balance;
    uint256 betFunds;
    uint256 bonus;
    uint256 kickback;
    uint256 brokerage;
    uint256 tax;
    uint256 income;
    uint ctime;
}
struct BetMessage {
    address player;
    uint8 command;
    uint256 betHash;
    uint256 amount;
    uint256 balance;
    uint256 betFunds;
    uint256 gas;
}
struct LotteryMessage {
    address player;
    bool isWin;
    uint256 betHash;
    uint256 blindHash;
    uint ctime;
}
