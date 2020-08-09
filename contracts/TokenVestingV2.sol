pragma solidity >=0.4.23 <0.6.0;
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
contract TokenVestingV2 {

    using SafeMath for uint256;
    //save gas , INS is an IERC20 no need to safe
    // using SafeERC20 for IERC20;

    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    
    uint256 public releasedAmount;
    IERC20 public token;

    constructor (address tokenAddr,address _beneficiary, uint256 _start, uint256 _duration) public {
        beneficiary = _beneficiary;
        duration = _duration;
        start = _start;
        token = IERC20(tokenAddr);
        
    }


    function release() public {
        uint256 unreleased = vestedAmount().sub(releasedAmount);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        releasedAmount = releasedAmount.add(unreleased);

        token.transfer(beneficiary, unreleased);

    }
    
    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(releasedAmount);

        if (block.timestamp < start) {
            return 0;
        } else if (block.timestamp >= start.add(duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}