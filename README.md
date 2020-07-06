# Technical-Training-Base
Material and Excercises for the Blockchain Technical Training

## Information

### Online IDE for Ethereum:

[https://remix.ethereum.org](https://remix.ethereum.org)

### Solidity Documentation 

[https://solidity.readthedocs.io/en/latest/](https://solidity.readthedocs.io/en/latest/)


## Tasks Voting Contract

### Task 1

Currently only the name and the current number of votes are displayed in the Proposal object. In order to create more transparency, the Ethereum address of the creator should also be added. Implement this requirement in the existing contract.

### Task 2

An attacker is trying to manipulate the election and has stolen a private key to gain access to another Ethereum address. The voter knows the compromised address and wants to exclude it from the vote. Empower the creator of the contract to deny certain addresses the right to participate in the vote.

### Task 3

Not everyone wants to take part in the vote themselves, but they do not want to waste their vote. Add the possibility to give other Ethereum addresses the right to vote for one's own person.

## Tasks ERC20 Contract

### Task 1

Modify the details of the Token (e.g. name of token) and deploy your own ERC20 Token to the private blockchain.
Send an arbitrary amount/number of token to another account and check the balance afterwards.

### Task 2

Similar to Task 3 of the previous exercise the ERC20 Token interface includes functions to transfer funds on account of somebody else. You can see that there are three functions in the code without content. 

Complete the three empty passages to:
* delegate own coins to somebody else
* spend coins of somebody else
* return the actual value one address delegated to another one

