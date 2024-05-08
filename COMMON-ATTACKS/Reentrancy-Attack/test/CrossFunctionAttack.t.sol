// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CrossFunction} from "../src/Cross-Function/CrossFunction.sol";
import {Attack} from "../src/Cross-Function/Attack.sol";


contract CrossFunctionAttack is Test {
    CrossFunction crossFunction;

    address tester = makeAddr("tester1");

    function setUp() public {
        crossFunction = new CrossFunction();
        vm.deal(tester, 100 ether);
    }

    function test_keepsTrackOfUsersDeposits() public {
        vm.prank(tester);
        crossFunction.deposit{value: 5 ether}();

        console.log(crossFunction.getBalance(tester));

        vm.prank(tester);
        crossFunction.withdraw(5 ether);

        console.log(crossFunction.getBalance(tester));
    }
}