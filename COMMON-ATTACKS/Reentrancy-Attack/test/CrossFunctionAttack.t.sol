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

     function test__attackScenerio() public {
         //NORMALUSER MAKES DEPOSIT INTO CROSSFUNCTION CONTRACT
         vm.prank(NORMALUSER);
         crossFunction.deposit{value: AMOUNT}();
         assertEq(address(crossFunction).balance, AMOUNT);
         assertEq(crossFunction.getBalance(address(NORMALUSER)), AMOUNT);

        // ATTACKER MAKES DEPOSIT AND WITHDRAW ALL BALANCE THROUGH ATTACK CONTRACT
        vm.startPrank(ATTACKER);
        console.log(ATTACKER.balance);
        attackContract.deposit{value: AMOUNT}();
        attackContract.withdraw();
        vm.stopPrank();
        console.log(ATTACKER.balance);


        //  // BALANCE OF THE CONTRACTS AFTER THE ATTACK
        // // console.log("Balance of the Attack contract after the attack is:", crossFunction.getBalance(address(attackContract)));
        // // console.log("CrossFunction contract balance after ATTACKER's deposit is:", address(crossFunction).balance);
        // // console.log(crossFunction.getBalance(ATTACKER));
    }
}