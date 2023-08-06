// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

contract YourContractName {
  constructor()public{
    
  }
  event Log(uint256 v);
  function test(uint256 v) public returns (uint256){
    require(v>=0,"ok");
    emit Log(v);
    return v;
  }
}
