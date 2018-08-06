pragma solidity ^0.4.23;


/**
 @title Standard ERC20 Token Interface.
 */
contract ERC20Interface {
    /**
     @dev Returns total tokens stored in the contract.
     */
    function totalSupply() public view returns (uint);

    /**
     * @dev Returns number of tokens owned by the specified address.
     * @param tokenOwner The address to query the balance of.
     * @return An uin256 representing balance of passed address.
     */
    function balanceOf(address tokenOwner) public view returns (uint balance);

    /**
     * @dev Retuens number of tokens approved by an address to another.
     * @param tokenOwner The address owns the funds.
     * @param spender The address which will spend the funds.
     * @return An uint256 specifying remaining number of tokens can be spent.
     */
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    
    /**
     * @dev Transfer a number of tokens from message sender address to a specified address.
     * @param to The address which tokens should be transfered to.
     * @param tokens Number of tokens should be transfered.
     * @return A bool that shows success or failure of process.
     */
    function transfer(address to, uint tokens) public returns (bool success);
    
    /**
     * @dev Approves the passed address to spend a specified number of tokens on behalf of msg.sender.
     * @param spender Address approved to spend the funds.
     * @param tokens Number of tokens approveed to be spent.
     * @return A bool that shows success or failure of process.
     */
    function approve(address spender, uint tokens) public returns (bool success);
    
    /**
     * @dev Transfers tokens from one address to another.
     * @param from The address will send tokens.
     * @param to The addrss will receive tokens.
     * @param tokens Number of tokens will be transfered.
     * @return A bool that shows success or failure of process.
     */
    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    /**
     * @dev Emits an event showing the transfer of tokens from one address to another.
     * @param from The address will send tokens.
     * @param to The addrss will receive tokens.
     * @param tokens Number of tokens will be transfered.
     */
    event Transfer(address indexed from, address indexed to, uint tokens);

    /**
     * @dev Emits an event showing Approval of the passed address to spend a specified 
     * number of tokens on behalf of msg.sender.
     * @param tokenOwner Address approved tokens being spent by spender.
     * @param spender Address being approved to spend the funds.
     * @param tokens Number of tokens approveed to be spent.
     * @return A bool that shows success or failure of process.
     */
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}