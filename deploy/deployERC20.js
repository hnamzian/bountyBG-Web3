var fs = require('fs');
var solc = require('solc');
var Web3 = require('web3');

files = [
    '../contracts/openZeppelin/math/SafeMath.sol',
    '../contracts/openZeppelin/ownership/Ownable.sol',
    '../contracts/openZeppelin/token/ERC20/ERC20.sol',
    '../contracts/openZeppelin/token/ERC20/ERC20Basic.sol',
    '../contracts/openZeppelin/token/ERC20/BasicToken.sol',
    '../contracts/openZeppelin/token/ERC20/StandardToken.sol'
]

main();

var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
        
function compile() {
    return new Promise((resolve, reject) => {
        let input = {};
        files.map(s => {input[s] = fs.readFileSync(s, 'utf8')});
        let output = solc.compile({sources : input}, 1);
        resolve(output);
    })
}

function getOwner() {
    return new Promise((resolve, reject) => {
        web3.eth.getAccounts()
        .then((accounts) => {
            resolve(accounts[0])
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
    const output = await compile();
    const abi = output.contracts['../contracts/openZeppelin/token/ERC20/StandardToken.sol:StandardToken'].interface
    const bytecode = output.contracts['../contracts/openZeppelin/token/ERC20/StandardToken.sol:StandardToken'].bytecode
    const owner = await getOwner();
    var token = await deploy(owner, abi, bytecode);
    console.log('Token Address: ' + token.options.address);
    console.log('Token Owner:   ' + owner)
}   