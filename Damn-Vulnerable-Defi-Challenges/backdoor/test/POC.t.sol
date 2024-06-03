// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WalletRegistry} from "../src/WalletRegistry.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {BackdoorAttacker} from "./BackdoorAttacker.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

contract POC is Test {
    WalletRegistry walletRegistry;
    GnosisSafe masterCopyAddress;
    GnosisSafeProxyFactory walletFactoryAddress;
    DamnValuableToken dvt;
    BackdoorAttacker attacker;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address david = makeAddr("david");
    address owner = makeAddr("owner");
    address player = makeAddr("player");

    address[] users = [alice, bob, charlie, david];
    uint256 AMOUNT_TOKENS_DISTRIBUTED = 40 ether;

    function setUp() public {
        vm.startPrank(owner);
        masterCopyAddress = new GnosisSafe();
        walletFactoryAddress = new GnosisSafeProxyFactory();
        dvt = new DamnValuableToken();

        walletRegistry = new WalletRegistry(address(masterCopyAddress), address(walletFactoryAddress), address(dvt), users);
        vm.stopPrank();
        
        //check owner
        assertEq(walletRegistry.owner(), owner);
        
        //check beneficiary
        for(uint256 i; i < users.length; i ++){
            assert(walletRegistry.beneficiaries(users[i]) == true);
        }

        //check users cannot add beneficiary
        vm.startPrank(alice);
        vm.expectRevert();
        walletRegistry.addBeneficiary(owner);
        vm.stopPrank();

        // Transfer tokens to be distributed to the registry
        vm.prank(owner);
        dvt.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        vm.prank(player);
        attacker = new BackdoorAttacker(address(dvt));
    }

    function test__canDrainRegistry() public {
        console.log(dvt.balanceOf(address(walletRegistry)));
        vm.startPrank(player);
        attacker.attack(address(walletFactoryAddress), address(masterCopyAddress), address(walletRegistry), users);
        vm.stopPrank();
        console.log(dvt.balanceOf(address(walletRegistry)));
    }
}
