// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

contract G2W_TEST {

    uint8 public value;

    function setValue(uint8 _value) external{
        require(_value > 10,"the parameter _value is must greater than 10.");
        value = _value;
    }

}