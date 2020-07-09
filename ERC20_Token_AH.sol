pragma solidity ^0.5.0;

// (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.

/*
Task 1
Modify the details of the Token (e.g. name of token) and deploy your own ERC20 Token to the private blockchain.
Send an arbitrary amount/number of token to another account and check the balance afterwards.

Task 2
Similar to Task 3 of the previous exercise the ERC20 Token interface includes functions to transfer funds on account of somebody else.
You can see that there are three functions in the code without content.
Complete the three empty passages to:
2-1 delegate own coins to somebody else
2-2 spend coins of somebody else
2-3 return the actual value one address delegated to another one
*/

// Safe maths library
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// Owned contract
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You shall not pass!");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// actual Token-Contract with a fixed supply
contract FixedSupplyToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // Constructor
    constructor() public {
        symbol = "GGG";
        name = "G-g-g...G-UNIT";
        _totalSupply = 1_000_000;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    // Total supply
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // Transfer the balance from token owner's account to `to` account
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Token owner can approve for `spender` to transferFrom(...) `tokens` from the token owner's account
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens; // allowance will not deductor freeze tokens at this point
        return true;
    }

    // Transfer `tokens` from the `from` account to the `to` account
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require((msg.sender == from || allowed[from][msg.sender] != 0), "Sorry, you have no business here!");
        require((balances[from] >= tokens && allowed[from][msg.sender] >= tokens), "Oops, not enough balance / allowance!");
        
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from, to, tokens);
        
        return true;
    }

    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        require(allowed[tokenOwner][spender] != 0, "You can't spend money from this"); // we only allow people with an actual allowance to check this
        return allowed[tokenOwner][spender];
    }

    // Don't accept ETH
    function () external payable {
        revert();
    }

    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
