// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

interface IGamblingContractFactory {
    function createBlindBoxContract(
        address _dealer,
        uint8 _luckyCount
    ) external returns (address);

    function enumDealer() external returns (address[] memory);

    event OnCreateGamblingContract(CreateGamblingContractMessage e);
}

struct CreateGamblingContractMessage {
    address contractAddress;
    address root;
    address dealer;
    uint8 luckyCount;
}
