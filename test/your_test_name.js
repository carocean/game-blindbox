const YourContractName = artifacts.require("YourContractName");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("YourContractName", function (/* accounts */) {
  it("should assert true", async function () {
    const your = await YourContractName.deployed();
    // await your.Log(function (v) {
    //   console.log(v);
    // });
    const value = await your.test(233);
    console.log('------'+value);
    return assert.equal(value, 233);
  });
});
