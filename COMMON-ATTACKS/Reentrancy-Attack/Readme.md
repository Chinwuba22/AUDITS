## Reentrancy Attack

Reentrancy Attack is a type of exploit where an exploter repeatedly calls a particular function, either to extract funds or to manipulate the state of any function/variable in a contract. The major cause of this attack is usually a failure to comply with the CEI(Checks, Effects, Interactions) principle which is a system used to update the state of a variable, or(and) failure to use a reentrant safeguard in functions which makes external calls.

Given the cause of this attack, the best way to avoid/limit the risk of it is to always ensure to follow the CEI principle or(and) use a reentrancy-guard when interacting with external contract.

[Reentrancy Guard example from Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol)

The different types of reentrancy-attack includes;
1. Classical type of reentrancy.
2. Cross function reentrancy.
3. Cross contract reentrancy.
4. Read only reentrancy.
5. ERC777 & ERC721 reentrancy.

## Classical Type of Reentrancy
[Code snippet](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Classical-Type/ClassicalType.sol) 

[Attack Contract](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Classical-Type/Attack.sol)


POC:
Explanation:

## Cross Function Reentrancy
Code snippet:
Attack Contract:
Explanation:

## Cross Contract Reentrancy
Code snippet:
Attack Contract:
Explanation:

## Cross Contract Reentrancy
Code snippet:
Attack Contract:
Explanation:

## Read Only Reentrancy
Code snippet:
Attack Contract:
Explanation:

## ERC777 & ERC721 Reentrancies
Code snippet:
Attack Contract:
Explanation:

## Breaking down 2 Complex Examples FIndings of Reentrancy From solodit.




