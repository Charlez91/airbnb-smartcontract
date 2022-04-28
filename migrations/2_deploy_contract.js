const Airbnb = artifacts.require("Airbnb");

module.exports = function (deployer) {
  deployer.deploy(Airbnb,"Airbnb Dapp Smart Contract");
};
