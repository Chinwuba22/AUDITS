// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CrossFunction} from "../src/Cross-Function/CrossFunction.sol";
import {Attack} from "../src/Cross-Function/Attack.sol";


contract CrossFunctionAttack is Test {
    CrossFunction crossFunction;
    Attack attackContract;

    address ATTACKER = makeAddr("attacker");
    address NORMALUSER = makeAddr("user");

    uint256 AMOUNT = 1 ether;

     function setUp() public {
        crossFunction = new CrossFunction();
        attackContract= new Attack(crossFunction, ATTACKER);
        vm.deal(ATTACKER, 4 ether);
        vm.deal(NORMALUSER, 4 ether);
     }

     function test_crossFunctionAttackScenerio() public {
         //NORMALUSER MAKES DEPOSIT INTO CROSSFUNCTION CONTRACT
         vm.prank(NORMALUSER);
         crossFunction.deposit{value: AMOUNT}();
         assertEq(address(crossFunction).balance, AMOUNT);
         assertEq(crossFunction.getBalance(address(NORMALUSER)), AMOUNT);

        // ATTACKER USES THE ATTACK CONTRACT TO MAKES DEPOSITS AND PLACE WITHDRAWAL
        uint256 startingBalance = address(attackContract).balance;
        vm.startPrank(ATTACKER);
        attackContract.deposit{value: AMOUNT}();
        attackContract.withdraw();
        vm.stopPrank();
        assertEq(address(attackContract).balance + startingBalance, AMOUNT);

        //ATTACKER WHO IS THE OWNER WITHDRAWS EXTRA BALANCE WHICH IS NOT HIS
        vm.prank(ATTACKER);
        crossFunction.withdraw(AMOUNT);
        assertEq(address(attackContract).balance + ATTACKER.balance, crossFunction.getBalance(address(NORMALUSER)) + 4 ether);

    }
}