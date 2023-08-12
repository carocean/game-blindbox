//@layout=layout.html
//@see https://www.npmjs.com/package/@truffle/contract
//引用web3
var Web3 = require("web3");
var fs = require('fs');
var path = require('path');
const requireNoCache = require("require-nocache")(module);
const url = require('url');

const test = async function (v) {
    var abifile = path.resolve('./') + '/build/contracts/YourContractName.json';
    // var contract_abi=fs.readFileSync(abifile);
    // fs.closeSync;
    // var abiText=JSON.parse(abif)
    // abifile=__dirname+'/YourContractName.json';
    const provider = new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545');
    // const contractArtifact = requireNoCache(abifile); //produced by Truffle compile
    const contractArtifact = require(abifile); //produced by Truffle compile
    const contract = require("@truffle/contract");

    const YourContractNameContract = contract(contractArtifact);
    YourContractNameContract.setProvider(provider);

    //https://github.com/trufflesuite/truffle/tree/master/packages/artifactor
    // const instance = await YourContractNameContract.at('0x745c61Ff48FF6234E6Ea5A01a9e8535854c08Db9');
    const instance = await YourContractNameContract.deployed();
    await instance.Log(function(error,event){
        console.log("event:"+parseInt(event.raw.data));
    })
    instance.test(v,{from:'0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F'}).then(function(e,f){
        console.log(f);
    });
    var result = await instance.test(v,{from:'0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F'});
    var v = parseInt(result);
    console.log(v);
    return v;
}

module.exports = (async function (req, res, _, $) {
    var uri = url.parse(req.url, true);
    var val = uri.query['value'];
    if (typeof val !== 'undefined') {
        var result = await test(parseInt(val));
        res.write(result+'');
        return;
    }
    var result = await test(24);
    $('div').attr('style', 'padding-top:100px;');
    $('label').html('合约YourContractNameContract.test返回值：');
    $('p').html(result + '');
    $('p').attr('style', 'color:red;font-size:30px;');
    _('.container').html($('div').prop('outerHTML'));
    var html = _('html').html();
    res.write(html);
});

