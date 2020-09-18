const ChainlinkOracle = artifacts.require("ChainlinkOracle");
const ExampleEthBackedToken = artifacts.require("ExampleEthBackedToken");

module.exports = async function(deployer) {
    // For some reason, this helps `oracle.address`
    // not be undefined??
    await web3.eth.net.getId();
    
    let oracle = await deployer.deploy(ChainlinkOracle);
    await deployer.deploy(ExampleEthBackedToken, oracle.address);
}