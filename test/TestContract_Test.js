const TestContract = artifacts.require("TestContract");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("TestContract", function (/* accounts */) {
  it("should assert true", async function () {
    const testContract = await TestContract.deployed();
    // await TestContract.test(function (v) {
    //   console.log(v);
    // });

    const value = await testContract.setValue(23,{from:'0xEe7D375bcB50C26d52E1A4a472D8822A2A22d94F'});
    console.log('------'+value);
    return assert.equal(value, 233);
  });
});
