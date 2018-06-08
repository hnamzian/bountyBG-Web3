var fs = require('fs');
var solc = require('solc');
var Web3 = require('web3');

tokenFiles = [
    './contracts/openZeppelin/math/SafeMath.sol',
    './contracts/openZeppelin/ownership/Ownable.sol',
    './contracts/openZeppelin/token/ERC20/ERC20.sol',
    './contracts/openZeppelin/token/ERC20/ERC20Basic.sol',
    './contracts/openZeppelin/token/ERC20/BasicToken.sol',
    './contracts/openZeppelin/token/ERC20/StandardToken.sol'
]

bountyFile = ['./contracts/bountyBG.sol']

var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
        
function compile(files) {
    return new Promise((resolve, reject) => {
        let input = {};
        files.map(s => {input[s] = fs.readFileSync(s, 'utf8')});
        let output = solc.compile({sources : input}, 1);
        resolve(output);
    })
}

function getOwner(index) {
    return new Promise((resolve, reject) => {
        web3.eth.getAccounts()
        .then((accounts) => {
            resolve(accounts[index])
        })
    })
}

function deploy(owner, abi, bytecode) {
    return new Promise((resolve, reject) => {
        new web3.eth.Contract(JSON.parse(abi))
        .deploy({data:bytecode})
        .send({from:owner, gas:3000000})
        .on('error', console.log)
        .then(resolve)
    })
}

async function main() {
    const tokenOutput = await compile(tokenFiles);
    const TokenABI = tokenOutput.contracts['./contracts/openZeppelin/token/ERC20/StandardToken.sol:StandardToken'].interface
    const TokenBytecode = tokenOutput.contracts['./contracts/openZeppelin/token/ERC20/StandardToken.sol:StandardToken'].bytecode
    const TokenOwner = await getOwner(0);
    var token = await deploy(TokenOwner, TokenABI, TokenBytecode);
    console.log('Token Address: ' + token.options.address);
    console.log('Token Owner:   ' + TokenOwner);

    const bountyOutput = await compile(bountyFile);
    const bountyABI = bountyOutput.contracts['./contracts/bountyBG.sol:BountyBG'].interface
    const bountyBytecode = bountyOutput.contracts['./contracts/bountyBG.sol:BountyBG'].bytecode
    const bountyOwner = await getOwner(1);
    var bountyBG = await deploy(bountyOwner, bountyABI, bountyBytecode);
    console.log('Bounty Address: ' + bountyBG.options.address);
    console.log('Bounty Owner:   ' + bountyOwner);

    const contracts = {
        'token address': token.options.address,
        'token owner': TokenOwner,
        'token abi': JSON.parse(TokenABI),
        'bounty address': bountyBG.options.address,
        'bounty owner': bountyOwner,
        'bounty abi': JSON.parse(bountyABI)
    }
    let data = JSON.stringify(contracts);  
    fs.writeFileSync('contracts.json', data);  
}   


main();