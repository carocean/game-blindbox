// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;
import "./IBlindBox.sol";
import "./BlindBoxContract.sol";
import "./IGamblingContractFactory.sol";

/**
 * @dev
 * Game contract factory, used by operators to apply for blind boxes.
 */
contract GamblingContractFactory is IGamblingContractFactory {
    address[] public contracts;
    mapping(address => address[]) private dealerIndexer;
    address[] private dealerKeys;
    address public root;

    constructor() {
        root = msg.sender;
    }

    modifier onlyRoot() {
        require(root == msg.sender, "Only root can call this.");
        _;
    }

    function enumDealer() public view override returns (address[] memory) {
        return dealerKeys;
    }

    function listContractOfDealer(
        address dealer
    ) public view override returns (address[] memory) {
        return dealerIndexer[dealer];
    }

    function createBlindBoxContract(
        address _dealer,
        uint8 _luckyCount
    ) external override onlyRoot returns (address) {
        BlindBoxContract blindBox = new BlindBoxContract(
            root,
            _dealer,
            _luckyCount
        );
        address blindBoxAddress = address(blindBox);
        contracts.push(blindBoxAddress);
        address[] storage contractAddressArr = dealerIndexer[_dealer];
        contractAddressArr.push(blindBoxAddress);
        bool foundKey = false;
        for (uint i = 0; i < dealerKeys.length; i++) {
            if (dealerKeys[i] == _dealer) {
                foundKey = true;
                break;
            }
        }
        if (!foundKey) {
            dealerKeys.push(_dealer);
        }
        CreateGamblingContractMessage
            memory cgcm = CreateGamblingContractMessage(
                blindBoxAddress,
                msg.sender,
                _dealer,
                _luckyCount
            );

        emit OnCreateGamblingContract(cgcm);
        return blindBoxAddress;
    }
}
