// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.9.0;

contract Voting {
    // Define a struct to store voter information
    struct Voter {
        address addr; // Voter's address

        bool registered; // Whether the voter is registered or not

        bool voted; // Whether the voter has voted or not

        uint256 vote; // The index of the candidate voted for
    }

    // Define a struct to store candidate information
    struct Candidate {
        string name; // Candidate's name

        uint256 voteCount; // The number of votes received

    }

    // Define a mapping to store voters by their address
    mapping(address => Voter) public voters;


    // Define a mapping to store candidates by their name
    mapping(string => Candidate) public candidates;


    // Define an array to store candidate names
    string[] public candidateNames;


    // Define the owner of the contract
    address public owner;


    // Define events to log important actions
    event VoterRegistered(address voter);
    event CandidateAdded(string candidate);
    event VoteCast(address voter, uint256 candidate);


    // Define a modifier to check if the caller is the owner
    modifier onlyOwner() {

        require(msg.sender == owner, "Only the owner can call this function");
        _;

    }


    // Define a constructor to initialize the contract with the owner
    constructor() {

        owner = msg.sender; // Set the owner to the deployer of the contract

    }


    // Define a function to register a voter
    function registerVoter(address _voter) public {

        require(!voters[_voter].registered, "The voter is already registered"); // Check if the voter is not registered
        
        voters[_voter] = Voter(_voter, true, false, 0); // Create a new voter struct and store it in the mapping
        
        emit VoterRegistered(_voter); // Emit an event for the voter registered
    }


    // Define a function to add a candidate
    function addCandidate(string memory _candidate) public onlyOwner {
        require(keccak256(abi.encodePacked(candidates[_candidate].name)) == keccak256(""), "The candidate already exists"); // Check if the candidate does not exist
       
        candidates[_candidate] = Candidate(_candidate, 0); // Create a new candidate struct and store it in the mapping
       
        candidateNames.push(_candidate); // Add the candidate name to the array
        
        emit CandidateAdded(_candidate); // Emit an event for the candidate added
    }


    // Define a function to cast a vote
    function vote(uint256 _candidate) public {
        
        require(voters[msg.sender].registered, "The voter is not registered"); // Check if the voter is registered
        
        require(!voters[msg.sender].voted, "The voter has already voted"); // Check if the voter has not voted
        
        require(_candidate < candidateNames.length, "The candidate index is invalid"); // Check if the candidate index is valid
        
        voters[msg.sender].vote = _candidate; // Store the candidate index in the voter struct
        
        voters[msg.sender].voted = true; // Mark the voter as voted
       
        string memory candidateName = candidateNames[_candidate]; // Get the candidate name from the array
        
        candidates[candidateName].voteCount++; // Increment the vote count of the candidate
       
        emit VoteCast(msg.sender, _candidate); // Emit an event for the vote cast
    }

    // Define a function to get the total number of candidates
    function getCandidateCount() public view returns (uint256) {
        return candidateNames.length; // Return the length of the candidate names array
    }

    // Define a function to get the winner of the election
    function getWinner() public view returns (string memory) {
        
        string memory winner; // Declare a variable to store the winner's name
       
        uint256 maxVotes = 0; // Declare a variable to store the maximum votes
       
        for (uint256 i = 0; i < candidateNames.length; i++) { // Loop through the candidate names array
        
            string memory candidateName = candidateNames[i]; // Get the candidate name from the array
        
            if (candidates[candidateName].voteCount > maxVotes) { // If the candidate has more votes than the current maximum
         
                winner = candidateName; // Update the winner's name
         
                maxVotes = candidates[candidateName].voteCount; // Update the maximum votes
         
            }
        }
        return winner; // Return the winner's name
    }
}
