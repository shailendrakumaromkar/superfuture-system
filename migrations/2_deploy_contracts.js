const Betting = artifacts.require("Betting");
// Deployed Contract
module.exports = function(deployer) {
  deployer.deploy(Betting);
};