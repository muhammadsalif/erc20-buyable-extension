// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./IERC20.sol";
import "./libraries/Safemath.sol";
import "./libraries/Address.sol";

contract MyToken is IERC20 {
    using SafeMath for uint256;
    using Address for address;

    // Mapping hold balances against EOA.
    mapping(address => uint256) private _balances;

    // Mapping to hold approved allowances of token to certain address
    mapping(address => mapping(address => uint256)) private _allowances;

    // Amount of token in existance
    uint256 private _totalSupply;

    address owner;
    string name;
    string symbol;
    uint8 decimals;
    uint256 private priceOfToken;

    constructor() {
        name = "MS-Token";
        symbol = "MS";
        decimals = 18;
        owner = msg.sender;

        // 1 millions token to be generated
        _totalSupply = 1000000 * 10**uint256(decimals);

        // Setting total supply (1 million) to token owner address
        _balances[owner] = _totalSupply;

        // fire an event on transfer of tokens
        emit Transfer(address(this), owner, _totalSupply);

        // setting price of token
        // E.g 1ether = 100 token; So: 1ether * 100;
        priceOfToken = 100;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        address sender = msg.sender;
        require(msg.sender != address(0), "Address Cant be zero address");
        require(
            !Address.isContract(sender),
            "Can't give tokens to contract address"
        );

        uint256 tokenToTransfer = msg.value * priceOfToken;
        require(
            _totalSupply > tokenToTransfer,
            "Total supply is less than token asked"
        );

        // sending token to sender account
        _balances[sender] = _balances[sender] + tokenToTransfer;

        // Minus total supply
        _totalSupply = _totalSupply - tokenToTransfer;

        // Minus from owner account
        _balances[owner] = _balances[owner] - tokenToTransfer;

        emit Transfer(owner, sender, tokenToTransfer);
    }

    // updating price of token
    function updatePricing(uint256 updatedPrice) public returns (bool) {
        address sender = msg.sender;
        require(sender == owner, "Only owner can change the price of tokens");
        priceOfToken = updatedPrice;
        return true;
    }

    // returning totalsupply remaining in contract
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // returning balanceOf that specific address
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // transfering amount from one account to another
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address sender = msg.sender; // the person who is calling this function
        require(sender != address(0), "Sender address is required"); // null address | burn address
        require(recipient != address(0), "Receipent address is required");
        require(_balances[sender] > amount, "Not suffecient funds");

        _balances[recipient] = _balances[recipient] + amount;
        _balances[sender] = _balances[sender] - amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // checking remaining amount of tokens that are approved to specific address
    function allowance(address _owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address sender = msg.sender; // the person who is calling this function
        require(sender != address(0), "Sender address is required"); // null address | burn address
        require(_balances[sender] > amount, "Not suffecient funds");

        _allowances[sender][spender] = amount;

        emit Approval(sender, spender, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        address spender = msg.sender; // the person who is calling this function
        require(
            sender != address(0),
            "Sender address should not be null address"
        );
        require(
            recipient != address(0),
            "Recipient address should not be null address"
        );
        require(_allowances[sender][spender] > amount, "Not allowed");

        // deducting allowance
        _allowances[sender][spender] = _allowances[sender][spender] - amount;
        // deducting sender amount from balance
        _balances[sender] = _balances[sender] - amount;
        // adding amount to recipient address
        _balances[recipient] = _balances[recipient] + amount;
        // firing event for dapp
        emit Transfer(sender, recipient, amount);

        return true;
    }
}
