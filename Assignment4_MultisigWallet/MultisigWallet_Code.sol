// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract MultiSig {

    // State variables to store owners, confirmation requirements, and transactions
    address[] public owners; // Array to store owner addresses

    uint public numConfirmationsRequired; // Number of confirmations required to execute a transaction

    struct Transaction {
        address to; // Address for the destination of the transaction's value

        uint value; // Value of the transaction in wei

        bool executed; // Flag to indicate if the transaction has been executed
    }

    // Mapping to track confirmations for each owner and each transaction
    mapping(uint => mapping(address => bool)) isConfirmed;

    // Array to store transaction data
    Transaction[] public transactions;

    // Events for logging important contract actions
    event TransactionSubmitted(uint transactionId, address sender, address receiver, uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    // Modifier to ensure that only owners can call the function
    modifier onlyOwner() {
        bool isOwnerFound = false;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwnerFound = true;
                break;
            }
        }
        require(isOwnerFound, "Not an owner");
        _;
    }

    // Constructor to initialize the contract with owners and confirmation requirements
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 1, "Owners Required Must Be Greater than 1");
        require(_numConfirmationsRequired > 0 && numConfirmationsRequired <= _owners.length, "Num of confirmations are not in sync with the number of owners");

        // Initialize owners array and confirmation requirements
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid Owner");
            owners.push(_owners[i]);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    // Function to submit a new transaction
    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid Receiver's Address");
        require(msg.value > 0, "Transfer Amount Must Be Greater Than 0");

        // Create a new transaction and add it to the transactions array
        uint transactionId = transactions.length;
        transactions.push(Transaction({ to: _to, value: msg.value, executed: false }));

        // Emit event to log the submission of a new transaction
        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    // Function to confirm a transaction
    function confirmTransaction(uint _transactionId) public {
        require(_transactionId < transactions.length, "Invalid Transaction Id");
        require(!isConfirmed[_transactionId][msg.sender], "Transaction Is Already Confirmed By The Owner");

        // Mark the transaction as confirmed by the current owner
        isConfirmed[_transactionId][msg.sender] = true;

        // Emit event to log the confirmation of a transaction
        emit TransactionConfirmed(_transactionId);

        // If the transaction has enough confirmations, execute it
        if (isTransactionConfirmed(_transactionId)) {
            // Execute the transaction directly from the confirmTransaction function
            executeTransaction(_transactionId);
        }
    }

    // Function to execute a transaction (only callable by owners)
    function executeTransaction(uint _transactionId) public payable onlyOwner {
        require(_transactionId < transactions.length, "Invalid Transaction Id");
        require(!transactions[_transactionId].executed, "Transaction is already executed");

        // Execute the transaction by sending the specified value to the destination address
        (bool success, ) = transactions[_transactionId].to.call{ value: transactions[_transactionId].value }("");
        require(success, "Transaction Execution Failed");

        // Mark the transaction as executed
        transactions[_transactionId].executed = true;

        // Emit event to log the execution of a transaction
        emit TransactionExecuted(_transactionId);
    }

    // Function to check if a transaction has enough confirmations
    function isTransactionConfirmed(uint _transactionId) internal view returns (bool) {
        require(_transactionId < transactions.length, "Invalid Transaction Id");
        uint confirmationCount; // Initially zero

        // Count the number of confirmations for the transaction
        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confirmationCount++;
            }
        }

        // Check if the required number of confirmations is reached
        return confirmationCount >= numConfirmationsRequired;
    }
}
