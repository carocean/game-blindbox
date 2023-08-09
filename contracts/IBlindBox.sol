// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

interface IBlindBox {
    function getState() external returns (BlindBoxState);

    function getBlindHash() external returns (uint256);

    function getBetHash() external returns (uint256);

    function foldBlindBox(uint256 _hash) external;

    function placeBet(
        uint8 luckyNumber,
        string memory nonce
    ) external payable returns (uint256);

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
    uint8 odds;
    uint8 brokerageRate;
    uint8 taxRate;
    uint256 balance;
    uint256 bonus;
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
    uint ctime;
}
struct LotteryMessage {
    address player;
    bool isWin;
    uint256 betHash;
    uint256 blindHash;
    uint ctime;
}
