pragma solidity ^0.4.17;


// ----------------------------------------------------------------------------
// C&#233;saire Burnable/Mintable token contract
//
// Symbol           : CSE
// Name             : C&#233;saire Token
// Total Supply     : 25,000,000
// Decimals         : 18


// ----------------------------------------------------------------------------
// Safe math
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c &gt;= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b &lt;= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b &gt; 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
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


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract CesaireToken is ERC20Interface {
    
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address public owner;

    mapping(address =&gt; uint) balances;
    mapping(address =&gt; mapping(address =&gt; uint)) allowed;
    
    
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 value);
    
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function CesaireToken() public {
        symbol = &quot;CSE&quot;;
        name = &quot;C&#233;saire Token&quot;;
        decimals = 18;
        _totalSupply = 25000000 * 10**uint(decimals);
        owner = 0x253568B1661CeBe59Fb602f1FEdF0131d3EAdC4c;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    
    // ------------------------------------------------------------------------
    // Reject when someone sends ethers to this contract
    // ------------------------------------------------------------------------
    function() public payable {
        revert();
    }
    
    
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner&#39;s account to `to` account
    // - Owner&#39;s account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        if(balances[msg.sender] &gt;= tokens &amp;&amp; tokens &gt; 0 &amp;&amp; to != address(0)) {
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;
        } else { return false; }
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner&#39;s account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        if(tokens &gt; 0 &amp;&amp; spender != address(0)) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        } else { return false; }
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        if (balances[from] &gt;= tokens &amp;&amp; allowed[from][msg.sender] &gt;= tokens &amp;&amp; tokens &gt; 0) {
            balances[from] = balances[from].sub(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(from, to, tokens);
            return true;
        } else { return false; }
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender&#39;s account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    
    // ------------------------------------------------------------------------
    // Increase the amount of tokens that an owner allowed to a spender.
    //
    // approve should be called when allowed[_spender] == 0. To increment
    // allowed value is better to use this function to avoid 2 calls (and wait until
    // the first transaction is mined)
    // From MonolithDAO Token.sol
    // _spender The address which will spend the funds.
    // _addedValue The amount of tokens to increase the allowance by.
    // ------------------------------------------------------------------------
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Decrease the amount of tokens that an owner allowed to a spender.
    //
    // approve should be called when allowed[_spender] == 0. To decrement
    // allowed value is better to use this function to avoid 2 calls (and wait until
    // the first transaction is mined)
    // From MonolithDAO Token.sol
    // _spender The address which will spend the funds.
    // _subtractedValue The amount of tokens to decrease the allowance by.
    // ------------------------------------------------------------------------
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Function to mint tokens
    // _to The address that will receive the minted tokens.
    // _value The amount of tokens to mint.
    // A boolean that indicates if the operation was successful.
    // ------------------------------------------------------------------------
    function mint(address _to, uint256 _value) onlyOwner public returns (bool) {
        require(_to != address(0));
        require(_value &gt; 0);
        _totalSupply = _totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Function to burn tokens
    // _value The amount of tokens to burn.
    // A boolean that indicates if the operation was successful.
    // ------------------------------------------------------------------------
    function burn(uint256 _value) onlyOwner public {
      require(_value &gt; 0);
      require(_value &lt;= balances[msg.sender]);
      address burner = msg.sender;
      balances[burner] = balances[burner].sub(_value);
      _totalSupply = _totalSupply.sub(_value);
      emit Burn(burner, _value);
      emit Transfer(burner, address(0), _value);
    }

}