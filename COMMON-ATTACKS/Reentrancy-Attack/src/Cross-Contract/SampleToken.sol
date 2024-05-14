pragma solidity 0.8.18;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract SampleToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    constructor() ERC20("SAMPLETOKEN", "ST"){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE){
        _mint(to, amount);
    }

    function burnAll(address from) public {
        uint256 balanceOfTo = balanceOf(from);
        _burn(from, balanceOfTo);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}