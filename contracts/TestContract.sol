// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.20;

contract TestContract {
    address public root;
    uint public value;

    constructor()  {
        root = msg.sender;
    }

    modifier onlyRoot() {
        require(root != msg.sender, "tttt");
        _;
    }

    function setValue(uint newValue) public onlyRoot{
        value = newValue;
    }
}