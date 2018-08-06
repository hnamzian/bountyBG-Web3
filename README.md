# bountyBG-Web3

BountyBG is an ethereum based smart contract developed in solidity. Everyone can post a new bounty and others can get rewards for solving these bounties. BountyBG supports both ether and any ERC20 tokens as bounty payments. Here a simple front-end is developed in html and CSS for the purpose of creating a new ERC20 bounty. Web3.js is a javascript library used to communicate with smart contracts on Ethereum Blockchain.

In additional to bountyBG contract, this project contains a Standard ERC20 token contract developed by openZeppelin so as to test the process of creating new ERC20 bounty.

# Requirements

NodeJS and npm are the fundamental requirements for running the project. You can install node and npm using the following links:



Other requirements are:

**truffle**: a development environment, testing framework and asset pipeline for Ethereum, aiming to make life as an Ethereum developer easier. Contracts could be compiled, tested and deployed by truffle easily. Please install truffle globlly:

```
npm install -g truffle
```

**ganache-cli**: Provides a local ethereum blockchain testnet. Contracts could be deployed to testnet in developement stage. Please install ganache-cli globally:

```
npm install -g ganache-cli
```

**solc**: Is a javascript library can be used to compile and deploy contracts. Please install solc locally:

```
npm install --save solc
```

**web3**: As mentioned web.js is javascript library with a lot functionality for the ethereum ecosystem. Please install it locally:

```
npm install web3
```

**live-server**: A little development server with live reload capability. Use it for hacking your HTML/JavaScript/CSS files, but not for deploying the final site. Please install it globally:

```
npm install -g live-server
```

# Compile constracts with truffle

In order to compile contracts using truffle, it could be easily done by the following command:

```
truffle compile
```

# Compile and Deploy contract

A Javascript file named deploy.js is provided for this purpose. It uses solc and web3 to orderly comile and deploy contracts to the ganache-cli testnet. Before deploying contract ganache-cli must be established by the following command in cmd or bash:

```
ganache-cli
```

If the testnet is established it provides 10 EOA with their public and private keys. Each one can be used to send transactions to contracts. Each Account has virtually 100 ethers.

Now running deploy.js, using following command, both bountyBG and Standard ERC20 token will be compiled and deployed to the provided testnet. Besides a json file named contract.json in deploy folder is created containing ABI, bytecode and contract owner of each contract.

```
npm run deploy
```

# How to use

The front-end is developed by HTML and CSS. In order to use the project first run live-server on any port you want (except 8545 of testnet) using the following command:

```
live-server --port=8080
```

Then a web page will immediately loaded on your browser. Pushing F12 key you can also see some logs in console for the purpose of debugging. 

On the top of the web page 3 tabs are provided:

**CREATE**: Enables a web page to create bounty.

**SETTINGS**: Enables some adjustments needed before creating a new bounty. Those are minimum bounty and bounty fee.

**Token**: This page is provided to interact with ERC20 Token. At this time only Approve tokens can be done.

### Create Bounty

Creating bounty involves 3 steps:

1- Go to the token page and the bounty poster must approve and amount of tokens from his/her balance to bountyBG contract. Import token address (it will be filled automatically at start time with our Standard token), select one of addresses as the user. Note that these are actually the premenioned assigned accounts created by testnet before. Also it must be considered that the first address is the token owner which ownes all tokens, and the second address is the bountyBG contract owner. As the token owner access to all tokens, use the first address from current user. Import bountyBG contract address as the spender Address (it will be filled automatically at start time with our Standard token) as the bounty poster should do it in order that bountyBG would then transfer token to its balance. Finally choose an amount of tokens should be transfered to bountyBG.

2- Go to SETTINGS page and import token address and set minimum bounty and bounty fee related this token.

3- Now you can go to CREATE page, having imported token address and bounty poster (the first address), choose a bounty Id and create your bounty.

Meanwhile doing above instructions you can watch the console pushhing get buttons to ensure everything is going as expected.
