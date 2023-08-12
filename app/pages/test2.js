var Web3 = require("web3");
var fs = require('fs');
var path = require('path');
const requireNoCache = require("require-nocache")(module);
const url = require('url');
const test = async function (v) {
    var abifile = path.resolve('./') + '/build/contracts/G2W_TEST.json';
    // var contract_abi=fs.readFileSync(abifile);
    // fs.closeSync;
    // var abiText=JSON.parse(abif)
    // abifile=__dirname+'/YourContractName.json';
    const provider = new Web3.providers.HttpProvider('ws://127.0.0.1:8545');
    // const contractArtifact = requireNoCache(abifile); //produced by Truffle compile
    const contractArtifact = require(abifile); //produced by Truffle compile
    const contract = require("@truffle/contract");

    const G2W_TESTContract = contract(contractArtifact);
    G2W_TESTContract.setProvider(provider);

    //https://github.com/trufflesuite/truffle/tree/master/packages/artifactor
    const instance = await G2W_TESTContract.at('0x799c48CE29b15a3396f2DA2E9963c2d60D793088');
    // const instance = await G2W_TESTContract.deployed();
    try {
        await instance.setValue(v, { from: '0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F' });
    } catch (e) {
        console.log(e);
        return;
    }
    var result = await instance.value();
    var v = parseInt(result);
    console.log(v);
    return v;
}

module.exports = (async function (req, res, _, $) {
    var uri = url.parse(req.url, true);
    var val = uri.query['value'];
    if (typeof val == 'undefined') {
        val = '100';
    }
    var result = await test(parseInt(val));
    console.log(result + '');
    res.write(result + '');
});