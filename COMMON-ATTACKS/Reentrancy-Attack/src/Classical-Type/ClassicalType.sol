// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

/**
 * @notice This Contract is a simple contract which allows users to deposit and withdraw ether.
 * @author Uba Chris (Extracted from https://solidity-by-example.org/hacks/re-entrancy/)
 */
contract CommonReentrancyExample {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
