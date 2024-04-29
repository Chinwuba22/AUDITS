// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {ClassicalType} from "../src/Classical-Type/ClassicalType.sol";
import {Attack} from "../src/Classical-Type/Attack.sol";

contract ClassicalTypeAttack is Test {
    ClassicalType public ct;
    Attack attackContract;

    address NORMALUSER = makeAddr("user");
    address ATTACKER = makeAddr("attacker");
    uint256 constant AMOUNT = 1 ether;

     function setUp() public {
        ct = new ClassicalType();
        attackContract= new Attack(address(ct));
        vm.deal(ATTACKER, 4 ether);
        vm.deal(NORMALUSER, 4 ether);
     }

     function test_attackScenerio() public {
        //GET INITIAL CONTRACT BALANCES
         console.log("ClassicalType contract balance is:", address(ct).balance);
         console.log("Attack contract balance is:", address(attackContract).balance);

         //NORMALUSER MAKES DEPOSIT INTO CLASSICALTYPE CONTRACT
         vm.prank(NORMALUSER);
         ct.deposit{value: AMOUNT}();
         console.log("ClassicalType contract balance after NORMALUSER's deposit is:", address(ct).balance);

         // ATTACKER MAKES DEPOSIT AND WITHDRAW ALL BALANCE THROUGH ATTACK CONTRACT
         console.log("Balance of the Attack contract before the attack is:", address(attackContract).balance);
         vm.startPrank(ATTACKER);
         attackContract.attack{value: AMOUNT}();
         vm.stopPrank();

         // BALANCE OF THE CONTRACTS AFTER THE ATTACK
         console.log("Balance of the Attack contract after the attack is:", address(attackContract).balance);
         console.log("ClassicalType contract balance after ATTACKER's deposit is:", address(ct).balance);
    }
}
