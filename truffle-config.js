
var HDWalletProvider = require("truffle-hdwallet-provider");
var mainnetPrivateKey=[""];


var testPrivKeys=[""]

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    goerli: {
      provider: function() {
      return  new HDWalletProvider(testPrivKeys, "");
         },
         network_id: '*',
         gasPrice:10000000000,
         networkCheckTimeout:99999999
      },

      mainnet: {
        provider: function() {
        return  new HDWalletProvider(mainnetPrivateKey, "");
           },
           network_id: '*',
           gasPrice:10000000000
        }        
  },
  solc: {
	 optimizer: {
	   enabled: true,
	   runs: 0
	 }
  } 
};
