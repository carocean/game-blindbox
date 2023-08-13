// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.20;
import "./IBlindBox.sol";
import "./BlindBoxContract.sol";
import "./IGamblingContractFactory.sol";
import "./SafeMath.sol";

/**
 * @dev
 * Game contract factory, used by operators to apply for blind boxes.
 */
contract GamblingContractFactory is IGamblingContractFactory {
    using SafeMath for *;
    address[] public contracts;
    mapping(address => address[]) private dealerIndexer;
    address[] private dealerKeys;
    address public root;
    mapping(address => ApplyRights) private rights;
    uint256 private annualFee = 4200000000000000000; //4.2 ether
    uint256 private monthlyFee = 400000000000000000; //0.4 ether

    constructor() {
        root = msg.sender;
    }

    modifier onlyRoot() {
        require(root == msg.sender, "Only root can call this.");
        _;
    }

    function getApplyRights(
        address dealer
    ) public view override returns (ApplyRights memory) {
        return rights[dealer];
    }

    function isPaidOfDealer(
        address dealer
    ) public view override returns (bool) {
        ApplyRights memory right = rights[dealer];
        return right.time != 0;
    }

    function isValidDealer(address dealer) public view override returns (bool) {
        ApplyRights memory right = rights[dealer];
        if (!right.isAllow) {
            return false;
        }
        if (right.time == 0) {
            return false;
        }
        (bool expired, ) = isExpired(dealer);
        return !expired;
    }

    function isExpired(
        address dealer
    ) public view override returns (bool, uint8) {
        ApplyRights memory right = rights[dealer];

        bool _expired;
        uint8 payMode = right.payMode;
        if (right.time == 0) {
            return (true, payMode);
        }
        if (payMode == 1) {
            _expired = (block.timestamp - right.time >= 31536000);
        }
        if (payMode == 2) {
            _expired = (block.timestamp - right.time >= 2678400);
        }
        return (_expired, payMode);
    }

    function getDealerCount() public view override returns (uint256) {
        return dealerKeys.length;
    }

    function getBlindboxCount() public view override returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < dealerKeys.length; i++) {
            address key = dealerKeys[i];
            address[] memory list = dealerIndexer[key];
            count = count.add(list.length);
        }
        return count;
    }

    function getBalance() public view override returns (uint256) {
        return address(this).balance;
    }

    function getAddress() public view override returns (address) {
        return address(this);
    }

    function getAnnualFee() public view override returns (uint256) {
        return annualFee;
    }

    function getMonthlyFee() public view override returns (uint256) {
        return monthlyFee;
    }

    function setAnnualFee(uint256 _annualFee) public override onlyRoot {
        require(_annualFee > 0, "Annual fee cannot be negative");
        annualFee = _annualFee;
    }

    function setMonthlyFee(uint256 _monthlyFee) public override onlyRoot {
        require(_monthlyFee > 0, "Monthly fee cannot be negative");
        monthlyFee = _monthlyFee;
    }

    function enumDealer() public view override returns (address[] memory) {
        return dealerKeys;
    }

    function listContractOfDealer(
        address dealer
    ) public view override returns (address[] memory) {
        return dealerIndexer[dealer];
    }

    ///@dev Create a new blind box
    function createBlindBoxContract(
        address _dealer,
        uint8 _luckyCount
    ) external override onlyRoot returns (address) {
        require(
            isValidDealer(_dealer),
            "Access to blind boxes is not allowed and must be paid or expired"
        );
        
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
                _luckyCount,
                rights[_dealer]
            );

        emit OnCreateGamblingContract(cgcm);
        return blindBoxAddress;
    }

    function withdraw() public payable override onlyRoot {
        (bool success, ) = payable(root).call{value: address(this).balance}(
            new bytes(0)
        );
        require(success, "ETH_TRANSFER_FAILED");
    }

    fallback() external payable {
        require(false, "No other calls supported");
    }

    ///@dev The default payment method is only used for charging annual fees
    receive() external payable {
        require(
            msg.value >= annualFee,
            "The fee should be at least equal to the annual fee"
        );
        rights[msg.sender] = ApplyRights(true, 1, block.timestamp);
    }

    function recMothlyFee() external payable override {
        require(
            msg.value >= monthlyFee,
            "The fee should be at least equal to the monthly fee"
        );
        rights[msg.sender] = ApplyRights(true, 2, block.timestamp);
    }
}
