// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SampleToken} from "./SampleToken.sol";


contract CrossContract is ReentrancyGuard {
    SampleToken sampleToken;

    constructor() {
        sampleToken = new SampleToken();
    }

    function deposit() payable public nonReentrant{
        require(msg.value > 0, "AMOUNT SENT MUST BE GREATER THAN ZERO");
        sampleToken.mint(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public nonReentrant{
        require(_amount > 0, "Not Enough Balance");

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "WITHDRAWAL FAILED");

        sampleToken.burnAll(msg.sender);
    }

    function getToken() external view returns(SampleToken) {
        return sampleToken;
    }
}