require("@nomiclabs/hardhat-waffle");
require('dotenv').config()

const PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [PRIVATE_KEY]
    }
  }
}
