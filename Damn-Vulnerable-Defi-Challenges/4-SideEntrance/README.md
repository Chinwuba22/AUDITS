## DESCRIPTION OF BUG

The issue here lies in the fact that `SideEntranceLenderPool` allows for deposits so when a flashloan is taken, and the `deposits` function is used as the the means to make the repayment, it will be possible for an attacker to drain the contract by also calling the `withdraw` function. Check out the `Test` folder for POC.
