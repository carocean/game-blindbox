// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;

import "./IBlindBox.sol";

import "./BlindBoxContract.sol";

interface IGamblingContractFactory {
    function createBlindBoxContract(
        address _dealer,
        uint8 _luckyCount
    ) external returns (address);

    function getDealerCount() external returns (uint256);

    function getBlindboxCount() external returns (uint256);

    function setAnnualFee(uint256 annualFee) external;

    function setMonthlyFee(uint256 monthlyFee) external;

    function getApplyRights(
        address dealer
    ) external returns (ApplyRights memory);

    function isPaidOfDealer(address dealer) external returns (bool);

    function isValidDealer(address dealer) external returns (bool);

    function isExpired(address dealer) external returns (bool, uint8);

    function getBalance() external returns (uint256);

    function getAddress() external returns (address);

    function getAnnualFee() external returns (uint256);

    function getMonthlyFee() external returns (uint256);

    function enumDealer() external returns (address[] memory);

    function listContractOfDealer(
        address dealer
    ) external returns (address[] memory);

    function withdraw() external payable;

    function recMothlyFee() external payable;

    event OnCreateGamblingContract(CreateGamblingContractMessage e);
}

struct CreateGamblingContractMessage {
    address contractAddress;
    address root;
    address dealer;
    uint8 luckyCount;
    ApplyRights rights;
}
struct ApplyRights {
    bool isAllow;
    uint8 payMode; //1:annualFee;2:monthlyFee
    uint time;
}
