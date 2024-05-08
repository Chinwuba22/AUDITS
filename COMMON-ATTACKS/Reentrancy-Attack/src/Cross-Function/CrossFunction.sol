// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CrossFunction is ReentrancyGuard {
    mapping(address => uint256) balances;

    function deposit() payable external {
        require(msg.value > 0, "MUST SEND A VALUE GREATER THAN ZERO");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public nonReentrant{
        uint256 usersBalance = balances[msg.sender];
        require(usersBalance >= amount, "NOT ENOUGH BALANCE");

        (bool success, ) = payable(msg.sender).call{value:amount}("");
        require(success, "WITHDRAWAL FAILED");

        balances[msg.sender] = usersBalance - amount;
    }

    function transfer(address to, uint256 amount) public {
        balances[msg.sender] -= amount;
        balances[to] += amount;

    }


    function getBalance(address user) public view returns (uint256){
        return balances[user];
    }
}