const url = require('url');
var Web3 = require("web3");
var path = require('path');
const contract = require("@truffle/contract");

const provider = new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545');
const web3 = new Web3(provider);

var factoryAbifile = path.resolve('./') + '/build/contracts/GamblingContractFactory.json';
const contractArtifact = require(factoryAbifile); //produced by Truffle compile
const GamblingContractFactory = contract(contractArtifact);
GamblingContractFactory.setProvider(provider);

const _getFactoryContract = async function () {
    const instance = await GamblingContractFactory.deployed();
    return instance;
}

const _create = async function (dealer, luckyCount) {
    var instance = await _getFactoryContract();
    await instance.OnCreateGamblingContract(function (error, msg) {
        var raw = msg.raw;
        var data = raw.data;
        var topics = raw.topics;
        var zz = web3.eth.abi.decodeLog([{
            type: 'address',
            name: 'contractAddress'
        }, {
            type: 'address',
            name: 'root'
        }, {
            type: 'address',
            name: 'dealer'
        }, {
            type: 'uint8',
            name: 'luckyCount'
        }],
            data,
            topics
        );
        console.log(zz);
    })
    var result = await instance.createBlindBoxContract(dealer, luckyCount, { from: '0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F' });
    console.log(result.receipt.status);//是否成功
    //单返回值解码
    var zz = web3.eth.abi.decodeParameter(
        "address",
        result.receipt.rawLogs[0].data
    );

    //单或多返回值解码，解码后为数组
    // var zz = web3.eth.abi.decodeParameters(
    //     ["address"],
    //     result.receipt.rawLogs[0].data
    // );
    return zz;
}
module.exports.create = async function (req, res) {
    var uri = url.parse(req.url, true);
    var dealer = uri.query['dealer'];
    var luckyCount = uri.query['luckyCount'];

    var address = await _create(dealer, luckyCount);
    console.log('newContract:' + address);
    var map = { contractAddress: address }

    res.end(JSON.stringify(map));
}

module.exports.dealers = async function (req, res) {
    var instance = await _getFactoryContract();
    var result = await instance.enumDealer();
    console.log(result);
    res.end(JSON.stringify(result));
}

module.exports.contracts = async function (req, res) {
    var uri = url.parse(req.url, true);
    var dealer = uri.query['dealer'];
    var instance = await _getFactoryContract();
    // var param=web3.eth.abi.encodeParameter('address',dealer);
    var result = await instance.listContractOfDealer(dealer);
    console.log(result);
    res.end(JSON.stringify(result));
}
module.exports.details = async function (req, res) {
    var abifile = path.resolve('./') + '/build/contracts/BlindBoxContract.json';
    const contractArtifact = require(abifile); //produced by Truffle compile
    const BlindBoxContract = contract(contractArtifact);
    BlindBoxContract.setProvider(provider);

    var uri = url.parse(req.url, true);
    var dealer = uri.query['dealer'];
    var address = uri.query['address'];
    const instance = await BlindBoxContract.at(address);
    // var param=web3.eth.abi.encodeParameter('address',dealer);
    // await instance.setValue(245,{from:dealer});
    var root = await instance.getRoot();
    var dealer = await instance.getDealer();
    var player = await instance.getPlayer();
    var state = await instance.getState();
    var luckyCount = await instance.luckyCount();
    var blindHash = await instance.getBlindHash();
    var betHash = await instance.getBetHash();
    var odds = await instance.odds();
    var kickbackRate = await instance.kickbackRate();
    var brokerageRate = await instance.brokerageRate();
    var taxRate = await instance.taxRate();
    var balance = await instance.getBalance();
    var betFunds = await instance.getBetFunds();
    var bonus = await instance.getBonus();
    var kickbackFunds = await instance.getKickbackFunds();
    var brokerageFunds = await instance.getBrokerageFunds();
    var taxFunds = await instance.getTaxFunds();
    var income = await instance.getIncome();
    var benefitRate = await instance.getBenefitRate();

    var map = {
        root: root,
        dealer: dealer,
        player: player,
        state: state,
        balance: web3.utils.fromWei(balance, 'ether'),
        luckyCount: parseInt(luckyCount),
        blindHash: blindHash,
        betHash: betHash,
        odds: parseInt(odds),
        kickbackRate:parseInt(kickbackRate),
        brokerageRate: parseInt(brokerageRate),
        taxRate: parseInt(taxRate),
        benefitRate:parseInt(benefitRate),
        betFunds:web3.utils.fromWei(betFunds, 'ether'),
        bonus:web3.utils.fromWei(bonus, 'ether'),
        kickbackFunds:web3.utils.fromWei(kickbackFunds, 'ether'),
        brokerageFunds:web3.utils.fromWei(brokerageFunds, 'ether'),
        taxFunds:web3.utils.fromWei(taxFunds, 'ether'),
        income:web3.utils.fromWei(income, 'ether'),
    };
    res.end(JSON.stringify(map));
}
module.exports.foldBlindBox = async function (req, res) {
    var abifile = path.resolve('./') + '/build/contracts/BlindBoxContract.json';
    const contractArtifact = require(abifile); //produced by Truffle compile
    const BlindBoxContract = contract(contractArtifact);
    BlindBoxContract.setProvider(provider);

    var uri = url.parse(req.url, true);
    var blindHash = uri.query['blindHash'];
    var address = uri.query['address'];
    const instance = await BlindBoxContract.at(address);
    var result = await instance.foldBlindBox(blindHash, { from: '0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F' });
    console.log(result);
}
module.exports.placeBet = async function (req, res) {
    var abifile = path.resolve('./') + '/build/contracts/BlindBoxContract.json';
    const contractArtifact = require(abifile); //produced by Truffle compile
    const BlindBoxContract = contract(contractArtifact);
    BlindBoxContract.setProvider(provider);

    var uri = url.parse(req.url, true);
    var player = uri.query['player'];
    var luckyNumber = uri.query['luckyNumber'];
    var nonce = uri.query['nonce'];
    var address = uri.query['address'];
    const instance = await BlindBoxContract.at(address);
    var result = await instance.placeBet(parseInt(luckyNumber), nonce, { from: player });
    console.log(result);
}
module.exports.lottery = async function (req, res) {
    var abifile = path.resolve('./') + '/build/contracts/BlindBoxContract.json';
    const contractArtifact = require(abifile); //produced by Truffle compile
    const BlindBoxContract = contract(contractArtifact);
    BlindBoxContract.setProvider(provider);

    var uri = url.parse(req.url, true);
    var luckyNumber = uri.query['luckyNumber'];
    var nonce = uri.query['nonce'];
    var address = uri.query['address'];
    const instance = await BlindBoxContract.at(address);
    var result = await instance.lottery(parseInt(luckyNumber), nonce, { from: '0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F', });
    console.log(result);
}
module.exports.onfeed = async function (req, res) {
    var abifile = path.resolve('./') + '/build/contracts/BlindBoxContract.json';
    const contractArtifact = require(abifile); //produced by Truffle compile
    const BlindBoxContract = contract(contractArtifact);
    BlindBoxContract.setProvider(provider);

    var uri = url.parse(req.url, true);
    var address = uri.query['address'];
    const instance = await BlindBoxContract.at(address);
    instance.BetEvent(function(error,msg){
        var raw = msg.raw;
        var data = raw.data;
        var topics = raw.topics;
        var zz = web3.eth.abi.decodeLog([{
            type: 'address',
            name: 'player'
        }, {
            type: 'uint8',
            name: 'command'
        }, {
            type: 'uint256',
            name: 'betHash'
        }, {
            type: 'uint256',
            name: 'amount'
        }, {
            type: 'uint256',
            name: 'balance'
        },, {
            type: 'uint256',
            name: 'betFunds'
        }, {
            type: 'uint256',
            name: 'gas'
        }],
            data,
            topics
        );
        console.log('--------');
        console.log(zz);
    })
}