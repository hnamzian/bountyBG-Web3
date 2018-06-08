const solc = require('solc');
const fs = require('fs');

const file = './contracts/bountyBg.sol';

let input = fs.readFileSync(file, 'utf8');

let output = solc.solc.compile(input, 1);

module exports = output;