## Re-entrancy Attack

Reentrancy Attack is a type of exploit where an exploter repeatedly calls a particular function, either to extract funds or to manipulate the state of any function/variable in a contract. The major cause of this attack is usually a failure to comply with the CEI(Checks, Effects, Interactions) principle which is a system used to update the state of a variable, or(and) failure to use a reentrant safeguard in functions which makes external calls.

Given the cause of this attack, the best way to avoid/limit the risk of it is to always ensure to follow the CEI principle or(and) use a reentrancy-guard when interacting with external contract.

[Reentrancy Guard example from Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol)

The different types of reentrancy-attack includes;
1. Classical type of reentrancy.
2. Cross function reentrancy.
3. Cross contract reentrancy.
4. Read only reentrancy.

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

Explanation: Cross-Function Reentrancy is used to refer to a type of reentrancy exploit where the mode of exploit is through 2 or more function. It is also important to mention that in any type of reentrancy, the root cause is still failure to update a particular variable state appropriately; that is, not duly complying with CEI. In the scenerio above, the mode of exploting the `CrossFunction::withdraw` is through the `CrossFunction::transfer`, and the reason why it was exploitable was because `balances[msg.sender] = usersBalance - amount;` which updates the state of balance only takes place after the external call `(bool success, ) = payable(msg.sender).call{value:amount}("");`. It is impossible to reenter the `CrossFunction::withdraw` as a result of the `nonReentrant` but was possible through `CrossFunction::transfer` as can be seen in the `Attack` contract. A simple fix for this would be to update the state first before making the external call.
```
 function withdraw(uint256 amount) public nonReentrant{
        uint256 usersBalance = balances[msg.sender];
        require(usersBalance >= amount, "NOT ENOUGH BALANCE");

        balances[msg.sender] = usersBalance - amount;

        (bool success, ) = payable(msg.sender).call{value:amount}("");
        require(success, "WITHDRAWAL FAILED");

    }
```

## Cross Contract Reentrancy
- [Code snippet](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Cross-Contract/CrossContract.sol)
- [Sample Token Contract](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Cross-Contract/SampleToken.sol)
- [Attack Contract](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/src/Cross-Contract/Attack.sol)
- [POC](https://github.com/Chinwuba22/AUDITS/blob/main/COMMON-ATTACKS/Reentrancy-Attack/test/CrossContractAttack.t.sol)

Explanation: Cross-contract reentrancy is a type of reentrancy where the mode of exploit is through a contract that is linked to the contract with the vulnerability. In the scenario above, the vulnerabilty lies in the fact that `CrossContract::withdraw` does not have any state which updates the balances upon an external call. This contract was exploited through `sampleToken.transfer(owner, balance);` in the `SampleToken::recieve` function. As same with the recommendation in the other type of reentrancy which has been discussed, a good solution would be to track and update state before any external call.

## Read Only Reentrancy
Explanation: Many standard projects contracts interact as a system where one code is extracted from the other, or there is a breakdown in different protocol logic is such a way that one contract rely on the other. When a contracts which has a reentrancy vulnerability is exploited, other contracts which relies on that particular contract automatically becomes exposed to an attack; this exposure is usally what is reffered to as a read-only reentrancy.







