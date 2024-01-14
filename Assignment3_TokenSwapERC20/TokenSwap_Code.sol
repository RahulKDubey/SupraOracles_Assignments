// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

// Define the ERC-20 interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Define the swap contract
contract Swap {
    // Declare the variables
    address public tokenA; // The address of Token A
    address public tokenB; // The address of Token B
    uint256 public rate; // The exchange rate between Token A and Token B
    address public owner; // The owner of the contract

    // Define the events
    event RateUpdated(uint256 newRate); // Emitted when the owner updates the exchange rate
    event Swapped(address indexed sender, address indexed receiver, address indexed token, uint256 amount, uint256 rate); // Emitted when a user swaps tokens

    // Create the constructor function
    constructor(address _tokenA, address _tokenB, uint256 _rate) {
        tokenA = _tokenA; // Set the address of Token A
        tokenB = _tokenB; // Set the address of Token B
        rate = _rate; // Set the initial exchange rate
        owner = msg.sender; // Set the owner of the contract
    }

    // Create the modifier that checks if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Create the function that allows the owner to update the exchange rate
    function updateRate(uint256 _rate) external onlyOwner {
        rate = _rate; // Update the exchange rate
        emit RateUpdated(rate); // Emit the event
    }

    // Create the function that allows users to swap Token A for Token B and vice versa
    function swap(address _token, uint256 _amount) external {
        require(_token == tokenA || _token == tokenB, "Invalid token address"); // Check if the token address is valid
        uint256 amountReceived; // Declare a variable to store the amount of tokens received
        if (_token == tokenA) { // If the user wants to swap Token A for Token B
            amountReceived = _amount * rate / 10**18; // Calculate the amount of Token B received
            require(IERC20(tokenB).balanceOf(address(this)) >= amountReceived, "Insufficient Token B balance"); // Check if the contract has enough Token B balance
            require(IERC20(tokenA).transferFrom(msg.sender, address(this), _amount), "Token A transfer failed"); // Transfer Token A from the user to the contract
            require(IERC20(tokenB).transfer(msg.sender, amountReceived), "Token B transfer failed"); // Transfer Token B from the contract to the user
        } else { // If the user wants to swap Token B for Token A
            amountReceived = _amount * 10**18 / rate; // Calculate the amount of Token A received
            require(IERC20(tokenA).balanceOf(address(this)) >= amountReceived, "Insufficient Token A balance"); // Check if the contract has enough Token A balance
            require(IERC20(tokenB).transferFrom(msg.sender, address(this), _amount), "Token B transfer failed"); // Transfer Token B from the user to the contract
            require(IERC20(tokenA).transfer(msg.sender, amountReceived), "Token A transfer failed"); // Transfer Token A from the contract to the user
        }
        emit Swapped(msg.sender, msg.sender, _token, _amount, rate); // Emit the event
    }
}