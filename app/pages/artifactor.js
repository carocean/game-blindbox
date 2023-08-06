
const build = function () {
    const Artifactor = require("@truffle/artifactor");
    const artifactor = new Artifactor(__dirname);
    artifactor.save(
        {
            contractName: "YourContractName",
            abi: [],
            bytecode: "0xabcdef",
            networks: '1338',
          }
    );
}

module.exports = (async function (req, res, _, $) {
    console.log('xxx');
    build();
});