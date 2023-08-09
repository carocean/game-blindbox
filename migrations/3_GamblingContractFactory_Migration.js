const GamblingContractFactory = artifacts.require("./GamblingContractFactory.sol");

module.exports = function (deployer) {
    deployer.deploy(GamblingContractFactory);
}
