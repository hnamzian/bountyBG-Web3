pragma solidity ^0.4.23;
import "./ERC20Interface.sol";


/**
 @title BountyBG contract to allow ones posting their bounties and in turn 
 * reward others have done bounty projects.
 */
contract BountyBG {

    address public owner;

    uint256 public bountyCount = 0;
    
    uint256 public bountyFee = 2 finney;
    uint256 public minBounty = 10 finney;
    
    mapping (address => uint256) bountyFeeToken;
    mapping (address => uint256) minBountyToken;

    enum paymentType {ETHER, ERC20}

    mapping (address => uint256) public bountyFeeCount;

    uint256 public bountyBeneficiariesCount = 2;
    uint256 public bountyDuration = 30 hours;
    uint256 public bountyDurationPsterAllowed = 48 hours;     

    mapping(uint256 => Bounty) bountyAt;

    event BountyStatus(string _msg, uint256 _id, address _from, uint256 _amount);
    event RewardStatus(string _msg, uint256 _id, address _to, uint256 _amount);
    event ErrorStatus(string _msg, uint256 _id, address _to, uint256 _amount);

    struct Bounty {
        uint256 id;
        address owner;
        uint256 bounty;
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Throws if called by any account other than the bounty poster.
     */
    modifier onlyPoster(uint _bountyId) {
        require(msg.sender == bountyAt[_bountyId].owner);
        _;
    }

    /**
     * @dev Throws if called by any account other than the bounty poster OR 
     * the contract owner only after the bounty deadline.
     */
    modifier allowedToReward(uint _bountyId) {
        require(
            msg.sender == bountyAt[_bountyId].owner || 
            ((msg.sender == owner) && 
            (bountyAt[_bountyId].startTime + bountyDurationPsterAllowed > block.timestamp)));
        _;
    }

    /**
     * @dev Withdraw an amount of Ether to the contract owner. Could be called only by owner.
     * @param _amount The amount of Eth must be transfered to the owner address.
     */
    function withdrawFee(uint256 _amount) external onlyOwner {
        require(_amount <= bountyFeeCount[this]);
        bountyFeeCount[this] -= _amount;
        owner.transfer(_amount);
    }

    /**
     * @dev Withdraw an amount of tokens of an ERC20 token to the contract owner. Could be called only by owner.
     * @param _amount The amount of Eth must be transfered to the owner address.
     * @param _tokanAdress The address of ERC20 Token contract.
     */
    function withdrawFeeToken(uint256 _amount, address _tokenAddress) external onlyOwner{
        require(_amount <= bountyFeeCount[_tokenAddress]);
        bountyFeeCount[_tokenAddress] -= _amount;
        ERC20Interface token = ERC20Interface(_tokenAddress);
        token.transfer(owner, _amount);
    }

    /**
     * @dev sets the duration of bounty projects.
     * @param _bountyDuration the duration of bounty project must be set.
     */
    function setBountyDuration(uint256 _bountyDuration) external onlyOwner {
        bountyDuration = _bountyDuration;
    }

    /**
     * @dev sets minimum amount of Ethers can be assigned as bounty rewards.
     * @param _minBounty minimum amount of Ethers for bounty rewards.
     */
    function setMinBounty(uint256 _minBounty) external onlyOwner {
        minBounty = _minBounty;
    }

    /**
     * @dev sets minimum token amount of a specified ERC20 Token.
     * @param _tokenAddress the token contract address.
     * @param _minBounty minimum bounty amount in token unit.
     */
    function setMinBountyToken(address _tokenAddress, uint256 _minBounty) external onlyOwner {
        minBountyToken[_tokenAddress] = _minBounty;
    }

    /**
     * @dev determines bounty fee in the unit of a specified ERC20 Token.
     * @param _tokenAddress the token contract address.
     * @param _bountyFee bounty Fee in token unit.
     */
    function setBountyFeeToken(address _tokenAddress, uint256 _bountyFee) external onlyOwner {
        bountyFeeToken[_tokenAddress] = _bountyFee;
    }

    /**
     * @dev sets number of beneficiaries of bounty projects.
     * @param _bountyBeneficiariesCount 
     */
    function setBountyBeneficiariesCount(uint256 _bountyBeneficiariesCount) external onlyOwner {
        bountyBeneficiariesCount = _bountyBeneficiariesCount;
    }

    /**
     * @dev transfers the specified amount of Ethers or ERC20 tokens to a set of users' addresses.
     * @param _bountyId bounty project id.
     * @param _users an array of users must be rewarded.
     * @param _rewards an array of Ether or Token amounts corresponded to users.

     */
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
                RewardStatus("Reward sent", bounty.id, _users[i], _rewards[i]);
            } else {
                ErrorStatus("Error in reward", bounty.id, _users[i], _rewards[i]);
            } */
        }
    }

    /**
     * @dev transfers a specified amount of Ethers or Tokens to a determined user.
     * @param _bountyId bounty project id.
     * @param _user the intended user to be rewarded.
     * @param _reward the amount of Ethers or Tokens must be rewarded.
     */
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

    /**
     * @dev creates a new bounty project with the payment of ETHER and sets its parameters.
     * @param _bountyId bounty project id.
     * (!!! _bountyId param seems to be unnecessary. actually bounty id must be set automatically not manually.)
     */
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

    /**
     * @dev creates a new bounty project with the payment of an ERC20 Token and sets its parameters.
     * @param _bountyId bounty project id.
     * @param _tokenAddress ERC20 Token contract address.
     * (!!! _bountyId param seems to be unnecessary. actually bounty id must be set automatically not manually.)
     */
    function createBountyERC20(uint256 _bountyId, address _tokenAddress) external payable {
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

    /**
     * @dev cancels a bounty corresponding to a specified bounty id.
     * @param _bountyId bounty project id.
     */
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

    /**
     * @dev returns the amount of Ethers stored in the contract.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev returns the parametrs of a specified bounty.
     * @param _bountyId bounty project id.
     */
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