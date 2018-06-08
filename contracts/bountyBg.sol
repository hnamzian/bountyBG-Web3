pragma solidity ^0.4.14;

contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BountyBG {

    address public owner;

    uint256 public bountyCount = 0;
    // uint256 public minBounty = 10 finney;
    // uint256 public bountyFee = 2 finney;

    uint256 public bountyFee = 2 finney;
    uint256 public minBounty = 10 finney;
    // my code: 
    // As the contract is supposed to support any ERC20 contract, the bountyFee and minBounty  
    // parameter must be determined according to token introduced by bounty owner.
    mapping (address => uint256) bountyFeeToken;
    mapping (address => uint256) minBountyToken;

    // my code: payment types are ether or erc20 type token
    enum paymentType {ETHER, ERC20}

    // uint256 public bountyFeeCount = 0;
    // my code: bounty fees must be counted with respect to token payments
    mapping (address => uint256) public bountyFeeCount;

    uint256 public bountyBeneficiariesCount = 2;
    uint256 public bountyDuration = 30 hours;
    uint256 public bountyDurationPosterAllowed = 48 hours; // or whatever you need


    mapping(uint256 => Bounty) bountyAt;

    event BountyStatus(string _msg, uint256 _id, address _from, uint256 _amount);
    event RewardStatus(string _msg, uint256 _id, address _to, uint256 _amount);
    event ErrorStatus(string _msg, uint256 _id, address _to, uint256 _amount);

    struct Bounty {
        uint256 id;
        address owner;
        uint256 bounty;
        
        // my code :
        // ParameterType: {'ETHER': payment is done by ethereum, 'ERC20': payment is done by any ERC20 Token.}
        // token Address: {if the payment is done by an ERC20 Token, here the token address must be registered,
        // -------------:  else, you can put the contract address or leave it blank.}
        paymentType payment;
        address tokenAddress;

        uint256 remainingBounty;
        uint256 startTime;
        uint256 endTime;
        bool ended;
        bool retracted;
    }

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPoster(uint _bountyId) {
        require(msg.sender == bountyAt[_bountyId].owner);
        _;
    }

    modifier allowedToReward(uint _bountyId) {
        require(
            msg.sender == bountyAt[_bountyId].owner || 
            (msg.sender == owner && bountyAt[_bountyId].startTime + bountyDurationPosterAllowed > block.timestamp));
        _;
    }

    // BLOCKGEEKS ACTIONS

    function withdrawFee(uint256 _amount) external onlyOwner {
        require(_amount <= bountyFeeCount[this]);
        bountyFeeCount[this] -= _amount;
        owner.transfer(_amount);
    }

    // my code: Now owner can also withdraw fees by other ERC20 tokens.
    // @_tokenAddress: ERC20 token Address
    function withdrawFeeToken(uint256 _amount, address _tokenAddress) external onlyOwner{
        require(_amount <= bountyFeeCount[_tokenAddress]);
        bountyFeeCount[_tokenAddress] -= _amount;
        ERC20Interface token = ERC20Interface(_tokenAddress);
        token.transfer(owner, _amount);
    }

    function setBountyDuration(uint256 _bountyDuration) external onlyOwner {
        bountyDuration = _bountyDuration;
    }

    function setMinBounty(uint256 _minBounty) external onlyOwner {
        minBounty = _minBounty;
    }

    // my code: Now for any ERC20 token owner can determine minimum bounty amount.
    // @tokenAddress: the token contract address.
    // @_minBounty: minimum bounty amount in token unit.
    function setMinBountyToken(address _tokenAddress, uint256 _minBounty) external onlyOwner {
        minBountyToken[_tokenAddress] = _minBounty;
    }

    function getMinBountyToken(address _tokenAddress) public view returns(uint256) {
        return minBountyToken[_tokenAddress];
    }

    // my code: Now for any ERC20 token owner can determine bounty fee amount.
    // @tokenAddress: the token contract address.
    // @_bountyFee: bounty Fee in token unit.
    function setBountyFeeToken(address _tokenAddress, uint256 _bountyFee) external onlyOwner {
        bountyFeeToken[_tokenAddress] = _bountyFee;
    }

    function getBountyFeeToken(address _tokenAddress) public view returns (uint256) {
        return bountyFeeToken[_tokenAddress];
    }

    function setBountyBeneficiariesCount(uint256 _bountyBeneficiariesCount) external onlyOwner {
        bountyBeneficiariesCount = _bountyBeneficiariesCount;
    }

    // code changed: rewardUsers now support payment in any ERC20 token.
    function rewardUsers(uint256 _bountyId, address[] _users, uint256[] _rewards) external allowedToReward(_bountyId) {
        Bounty storage bounty = bountyAt[_bountyId];
        require(
            !bounty.ended &&
            !bounty.retracted &&
            bounty.startTime + bountyDuration > block.timestamp &&
            _users.length > 0 &&
            _users.length <= bountyBeneficiariesCount &&
            _users.length == _rewards.length
        );

        bounty.ended = true;
        bounty.endTime = block.timestamp;
        uint256 currentRewards = 0;
        for (uint8 i = 0; i < _rewards.length; i++) {
            currentRewards += _rewards[i];
        }

        require(bounty.bounty >= currentRewards);

        if (bounty.payment == paymentType.ERC20) {
            address tokenAddress = bounty.tokenAddress;
            ERC20Interface token = ERC20Interface(tokenAddress);
        }

        for (i = 0; i < _users.length; i++) {
            if (bounty.payment == paymentType.ETHER) {
                _users[i].transfer(_rewards[i]);    
            } else {
                token.transfer(_users[i], _rewards[i]);
            }
            
            emit RewardStatus("Reward sent", bounty.id, _users[i], _rewards[i]);
            /* if (_users[i].send(_rewards[i])) {
                bounty.remainingBounty -= _rewards[i];
                RewardStatus('Reward sent', bounty.id, _users[i], _rewards[i]);
            } else {
                ErrorStatus('Error in reward', bounty.id, _users[i], _rewards[i]);
            } */
        }
    }

    // code changed: rewardUser now support payment in any ERC20 token.
    function rewardUser(uint256 _bountyId, address _user, uint256 _reward) external onlyPoster(_bountyId) {
        Bounty storage bounty = bountyAt[_bountyId];
        require(bounty.remainingBounty >= _reward);
        
        bounty.remainingBounty -= _reward;
        bounty.ended = true;
        bounty.endTime = block.timestamp;
        
        if (bounty.payment == paymentType.ETHER) {
            _user.transfer(_reward);
        } else {
            address tokenAddress = bounty.tokenAddress;
            ERC20Interface token = ERC20Interface(tokenAddress);
            token.transfer(_user, _reward);
        }

        emit RewardStatus("Reward sent", bounty.id, _user, _reward);
    }

    // USER ACTIONS TRIGGERED BY METAMASK

    function createBounty(uint256 _bountyId) external payable {
        require(
            msg.value >= minBounty + bountyFee
        );
        Bounty storage bounty = bountyAt[_bountyId];
        require(bounty.id == 0);
        bountyCount++;
        bounty.id = _bountyId;
        bounty.bounty = msg.value - bountyFee;
        bounty.remainingBounty = bounty.bounty;
        bounty.payment = paymentType.ETHER;
        bounty.tokenAddress = this;
        bountyFeeCount[this] += bountyFee;
        bounty.startTime = block.timestamp;
        bounty.owner = msg.sender;
        emit BountyStatus("Bounty submitted", bounty.id, msg.sender, msg.value);
    }

    // my code: createBountyERC20 is added for when one can create a new bounty but to pay in an ERC20 token
    // @_tokenAddress: ERC20 token address which by payment will be done.
    ///// not needed to be payable
    function createBountyERC20(uint256 _bountyId, address _tokenAddress) external {
        ERC20Interface token = ERC20Interface(_tokenAddress);
        require(
            minBountyToken[_tokenAddress] > 0 &&
            bountyFeeToken[_tokenAddress] > 0 &&
            token.allowance(msg.sender, this) >= minBountyToken[_tokenAddress] + bountyFeeToken[_tokenAddress]
        );
        uint256 bountyAmount = token.allowance(msg.sender, this);
        token.transferFrom(msg.sender, this, bountyAmount);
        Bounty storage bounty = bountyAt[_bountyId];
        require(bounty.id == 0);
        bountyCount++;
        bounty.id = _bountyId;
        bounty.bounty = bountyAmount - bountyFeeToken[_tokenAddress];
        bounty.remainingBounty = bounty.bounty;
        bounty.payment = paymentType.ERC20;
        bounty.tokenAddress = _tokenAddress;
        bountyFeeCount[bounty.tokenAddress] += bountyFeeToken[_tokenAddress];
        bounty.startTime = block.timestamp;
        bounty.owner = msg.sender;
        emit BountyStatus("Bounty submitted with ERC20", bounty.id, msg.sender, bountyAmount);
    }

    // code changed: cancelBounty now support payments with any ERC20 token.
    function cancelBounty(uint256 _bountyId) external {
        Bounty storage bounty = bountyAt[_bountyId];
        require(
            msg.sender == bounty.owner &&
            !bounty.ended &&
            !bounty.retracted &&
            bounty.owner == msg.sender &&
            bounty.startTime + bountyDuration < block.timestamp
        );
        bounty.ended = true;
        bounty.retracted = true;
        if (bounty.payment == paymentType.ETHER) {
            bounty.owner.transfer(bounty.bounty);
        } else {
            address tokenAddress = bounty.tokenAddress;
            ERC20Interface token = ERC20Interface(tokenAddress);
            token.approve(bounty.owner, bounty.bounty);
        }
        emit BountyStatus("Bounty was canceled", bounty.id, msg.sender, bounty.bounty);
    }

    // CUSTOM GETTERS

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getBounty(uint256 _bountyId) external view
    returns (uint256, address, uint256, uint256, uint256, uint256, bool, bool) {
        Bounty memory bounty = bountyAt[_bountyId];
        return (
            bounty.id,
            bounty.owner,
            bounty.bounty,
            bounty.remainingBounty,
            bounty.startTime,
            bounty.endTime,
            bounty.ended,
            bounty.retracted
        );
    }
}