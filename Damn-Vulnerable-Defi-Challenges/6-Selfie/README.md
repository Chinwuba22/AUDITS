## DESCRIPTION OF BUG

The issues in this code lies in the fact that anyone can call `DamnValuableTokenSnapshot::snapshot`, and that the governance contract in `SimpleGovernance::queueAction` allows does not have any limit or checks on what can be passed in the bytes parameter and the pool contracts opens up a loophole in emergencyExit making it possible to drain the contract.