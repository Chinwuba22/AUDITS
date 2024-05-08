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
- [Code snippet](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Classical-Type/ClassicalType.sol) 
- [Attack Contract](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Classical-Type/Attack.sol)
- [POC](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/test/ClassicalType.t.sol)

Explanation: Classical Reentrancy is generally used to refer to the simplest form of an reentrnacy. From the scenario above, the reason why it is possible to exploit the `ClassicalType` contract is because its withdraw function fails to update the state of the msg.sender before the external call. That is, because it failed to comply with CEI.

```
function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }
```
The `balances[msg.sender] = 0` as seen above, which updates the balance of the msg.sender was only updated after the external call ` (bool sent,) = msg.sender.call{value: bal}("");`, implying that for every withdrawal, funds are first taken out before the contracts updates the balance state which is the main cause of a reentrancy attack. The attacker as seen in the `Attack` contract was able to exploit this vulnerability through implementing a `fallback` function which tries to withdraw 1 ether in addition to his initial balance which in the case above was the `ClassicalType` contracts balance.
```
fallback() external payable {
        if (address(ct).balance >= AMOUNT) {
            ct.withdraw();
        }
    }
```
A good recommendation to the would be to implement a a reentrant modifier, or to ensure that state is updated before any external call;
```
function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
    }
```


## Cross Function Reentrancy
- [Code snippet](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Cross-Function/CrossFunction.sol)
- [Attack Contract](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Cross-Function/Attack.sol)
- [POC](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/test/CrossFunctionAttack.t.sol)

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




