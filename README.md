# SupraOracles_Assignments

FOR THE DECENTRALISED VOTING CODE :


  The owner can only add candidates.
  Voters can register themselves through there address. 
  Voters can vote to candidate's id.
  The winner is publicly accessible.
  rest of the functions are simple to use.


FOR TOKEN SWAP OF ERC-20 TOKENS :

  The constructor input field will be token address of A and B and the exchange rate.


FOR MULTI-SIGNATURE WALLET :


  STEP 1 : The constructor have two inputs the owner field and confirmations field 


  STEP 2: The format for giving address of owner is ["0x..Ca","0x..Ab"] like this we can add as many owner as we want and the confirmation field will be less than or equal 
  to the number of owner.


  STEP 3: Then any address can enter a value in the value field and select the option whether in wei, eth or else then provide address of recipient in the submittransaction function.


  STEP 4: After that the owners need to confirm the transaction by its I'd and the execute function will be called by self once the required number of confirmation value is met.


  rest of the function are simple to use.



For 
