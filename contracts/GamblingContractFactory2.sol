// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;
import "./IBlindBox.sol";
//示例：调用已部署好的合约
contract GamblingContractFactory2 {
    address private delegator;
    address public root;

    constructor(address _delegator, address _root) {
        delegator = _delegator;
        root = _root;
    }

    modifier onlyRoot() {
        require(msg.sender != root, "must root");
        _;
    }

    function getState() external returns (BlindBoxState) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("getState()")
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (BlindBoxState));
    }

    function setBlindHash(string memory _hash) external {
        (bool success, ) = delegator.delegatecall(
            abi.encodeWithSignature("setBlindHash()", _hash)
        );
        require(success, "delegatecall failed");
    }

    function getBlindHash() external returns (string memory) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("getBlindHash()")
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (string));
    }

    function getBetHash() external returns (string memory) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("getBetHash()")
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (string));
    }

    function placeBet(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (string memory) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("placeBet()", _luckyNumber, _nonce)
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (string));
    }

    function lottery(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (bool) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("placeBet()", _luckyNumber, _nonce)
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (bool));
    }

    function isWin(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (bool) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("isWin()", _luckyNumber, _nonce)
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (bool));
    }

    function getHash(
        uint8 _luckyNumber,
        string memory _nonce
    ) external returns (string memory) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature("getHash()", _luckyNumber, _nonce)
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (string));
    }

    function compareHash(
        uint8 _luckyNumber,
        string memory _nonce,
        string memory _toHash
    ) external returns (bool) {
        (bool success, bytes memory data) = delegator.delegatecall(
            abi.encodeWithSignature(
                "compareHash()",
                _luckyNumber,
                _nonce,
                _toHash
            )
        );
        require(success, "delegatecall failed");
        return abi.decode(data, (bool));
    }
}
