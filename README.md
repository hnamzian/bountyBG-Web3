# bountyBG-Web3

BountyBG is an ethereum based smart contract wdeveloped in solidity. Everyone can post a new bounty and others can get rewards for solving
these bounties. BountyBG supports both ether and any ERC20 tokens as bounty payments. Here a simple front-end is developed in html5 and CSS for the purpose of creating a new ERC20 bounty. Web3.js is a javascript library used to communicate with smart contracts on Ethereum Blockchain.
Besides bountyBG contract this project contains a Standard ERC20 token developed by openZeppelin so as to test the process of creating new ERC20 bounty.

# Requirements

NodeJS and npm are the fundamental requirements for running the project. You can install node and npm using the following links:



Other requirements are:

truffle: a development environment, testing framework and asset pipeline for Ethereum, aiming to make life as an Ethereum developer easier. Contracts could be compiled, tested and deployed by truffle easily. Please install truffle globlly:

```
npm install -g truffle
```

ganache-cli: Provides a local ethereum blockchain testnet. Contracts could be deployed to testnet in developement stage. Please install ganache-cli globally:

```
npm install -g ganache-cli
```

solc: Is a javascript library can be used to compile and deploy contracts. Please install solc locally:

```
npm install --save solc
```

web3: As mentioned web.js is javascript library with a lot functionality for the ethereum ecosystem. Please install it locally:

```
npm install web3
```

# Compile constracts with truffle

In order to compile contracts using truffle, it could be easily done by the following command:

```
truffle compile
```

#Compile and Deploy contract

A Javascript file named deploy.js is provided for this purpose. It uses solc and web3 to orderly comile and deploy contracts to the ganache-cli testnet. Before deploying contract ganache-cli must be established by the following command in cmd or bash:

```
ganache-cli
```

If the testnet is established it provides 10 EOA with their public and private keys. Each one can be used to send transactions to contracts. Each Account has virtually 100 ethers.

Now running deploy.js both bountyBG and Standard ERC20 token will be compiled and deployed to the provided testnet. Besides a json file named contract.json in deploy folder is created containing ABI, bytecode and contract owner of each contract.
