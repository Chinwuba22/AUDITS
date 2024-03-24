## DESCRIPTION OF BUG

The issue here lies in the fact that `TrusterLenderPool::flashloan` allows for anyone to pass in any function as parameter into it. So if an approval function is passed into the function, there will be an oppurtunity to withdraw all the balance in the contract. Check `Attacker` contract and the test contract in `TestTrusterLenderPool.t.sol` file for POC.
