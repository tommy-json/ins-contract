pragma solidity >=0.5.0 <0.7.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

contract InsToken is ERC20Mintable{
    string  public  constant name="INS";
    string  public  constant symbol="INS";
    string  public  constant version = "1.0";
    uint256  public  decimals = 18;
}