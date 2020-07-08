pragma solidity >=0.4.22 <0.6.0;

/*
Task 1
Currently only the name and the current number of votes are displayed in the Proposal object.
In order to create more transparency, the Ethereum address of the creator should also be added.
Implement this requirement in the existing contract.
    Possible solution:
    1a. Add a variable/field to the object to store the address.
    1b. Add the msg.sender as new parameter to new Proposal objects, since only creator=chairperson is allowed to use that constructor.
    1c. For even more transparency: also display the address of the Proposal creator for the winning Proposal

Task 2
An attacker is trying to manipulate the election and has stolen a private key to gain access to another Ethereum address.
The voter knows the compromised address and wants to exclude it from the vote.
Empower the creator of the contract to deny certain addresses the right to participate in the vote.
    Possible solution:
    2a. Create a ban-list that stores addresses known to be denied of voting.
        Ban-list should be a mapping rather than an array (arrays in Solidity can only be iterated not searched and thus may get costly)
        Ban-list could alternatively bean array of objects which could potentially hold more information than just the addresses. See problem with arrays though.
    2b. Create a function to allow adding entries to the list. Allow only the creator of the contract to use that function.
    2c. Create a comparison or simple condition that checks sender-adresses from incoming votes against the ban-list before counting a vote.
    

Task 3
Not everyone wants to take part in the vote themselves, but they do not want to waste their vote.
Add the possibility to give other Ethereum addresses the right to vote for one's own person.
    Possible solution(s):
        Either create an option to increase a voters number of votes per Proposal
        or alter the structure of voter to allow for delegates. Let's go for more votes.
    3a. Add a variable to the Voter how many votes he has (default 1)
    3b. Create a function that increases votes for a delegate and voids the senders own vote
    3c. Alter vote function to count down a voters number of votes before denying him further votings.
*/

contract Poll {

    struct Voter {
        uint votes;
        bool voted; // Technically redundant after Task 3 solution but kept it just for revision purposes
        uint vote;
    }
    
    struct Proposal {
        string name;
        uint voteCount;
        address creatorAdress; //Task 1, Step 1a
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    mapping(address => bool) bannedAdresses;
    Proposal[] public proposals;

    constructor() public {
        chairperson = msg.sender;
    }
    
    function addProposal(string memory proposalName) public {
        require(msg.sender == chairperson, "Sorry, you don't get to add proposals. Ask mom.");
        proposals.push(
            Proposal(proposalName, 0, msg.sender)  //Task 1, Step 1b
        );
    }
    
    function banVoter(address bannedVoter) public {
        require(msg.sender == chairperson);
        bannedAdresses[bannedVoter] = true;
    }
    
    // Task 3, Step 3b
    function delegateVote(address delegate) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You can't delegate your vote because you already voted.");
        voters[delegate].votes++;
        sender.votes--;
        voters[delegate].voted = false;
        if (sender.votes == 0){
            sender.voted = true;
        }
    }
    
    function vote(uint proposalNumber) public {
        Voter storage sender = voters[msg.sender];
        require(!bannedAdresses[msg.sender], "Your account has been suspended from voting."); //Task 2, Step 2c
        require(!sender.voted, "Already voted.");
        
        // Task 3, Step 3b
        sender.votes++; // Task 3, ugly workaround for the moment to ensure a voter could vote at least once if he didn't delegate
        sender.votes--;
        if (sender.votes == 0){
            sender.voted = true;
        }
        sender.vote = proposalNumber;
        proposals[proposalNumber].voteCount += 1;
    }

    function winningProposal() public view returns (uint winningProposalNumber) {
        uint winningVoteCount = 0;
        
        // iterate the array to determine the winner
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposalNumber = p;
            }
        }
    }

    function winnerName() public view returns (string memory winnerName_) {
        require(proposals.length!=0, "There is no proposal in the list!");
        uint winningProposalIndex = winningProposal();                                                                                                   //Task 1, Step 1c
        winnerName_ = string(abi.encodePacked(proposals[winningProposalIndex].name, " proposed by ", proposals[winningProposalIndex].creatorAdress));    //Task 1, Step 1c
    }

}
