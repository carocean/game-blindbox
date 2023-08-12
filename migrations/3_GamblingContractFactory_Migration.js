const GamblingContractFactory = artifacts.require("./GamblingContractFactory.sol");
const BlindBoxContract = artifacts.require("./BlindBoxContract.sol");
module.exports = function (deployer, network, accounts) {
    for (var i = 0; i < accounts.length; i++) {
        var a = accounts[i];
        console.log(a);
    }
    deployer.deploy(BlindBoxContract, accounts[0], accounts[0], 5);
    deployer.deploy(GamblingContractFactory);
}
