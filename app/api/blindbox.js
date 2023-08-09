const url = require('url');
var Web3 = require("web3");
var path = require('path');
const contract = require("@truffle/contract");

var abifile = path.resolve('./') + '/build/contracts/GamblingContractFactory.json';
const provider = new Web3.providers.WebsocketProvider('ws://192.168.0.254:8545');
const web3 = new Web3(provider);
const contractArtifact = require(abifile); //produced by Truffle compile
const GamblingContractFactory = contract(contractArtifact);
GamblingContractFactory.setProvider(provider);

const _getContract = async function () {
    const instance = await GamblingContractFactory.deployed();
    return instance;
}

const _create = async function (dealer, luckyCount) {
    var instance = await _getContract();
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
    var instance = await _getContract();
    var result = await instance.enumDealer();
    console.log(result);
    res.end(JSON.stringify(result));
}