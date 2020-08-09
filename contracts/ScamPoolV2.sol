

pragma solidity >=0.4.23 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./IUniswapV2Router01.sol";
import "./TokenVestingV2.sol";
contract ScamPoolV2  is Ownable{
    using SafeMath for uint256;
    //useraddres=>VestiongContractAddresses
    mapping(address=>address[]) public userVestingContractArray;

    mapping(address=>uint256) public userInvestAmount;
    mapping(address=>uint256) public userInvestCount;
    uint256 public investCount ;

    ERC20Mintable public insToken;

    address public insTokenAddr;

    

    address payable public uniswapToAddr;

    address payable public uniswapAddr;
    IUniswapV2Router01 public uniswap;

    constructor () public {
        insTokenAddr=0xA7cfd735C14aDdD0Ff43ed2586521dCfc9B8193F;
        insToken = ERC20Mintable (insTokenAddr);
        
        
        uniswapAddr=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        uniswap = IUniswapV2Router01(uniswapAddr);
        uniswapToAddr = 0x564bF479cb8fD7bC22c46B98838D1e80Bbf82065;


        //approve enough ins to uniswap
        _increaseApprove(999999999999000000000000000000);
    }

   
    function invest() external payable {
        require(msg.value>=0.1 ether,"not match the require ether");

        //80% to liquid
        uint256 liquidETH = msg.value.div(100).mul(80);
        uint256 liquidToken = liquidETH.mul(10);

        
        uint256 airdropToekn = msg.value.mul(30);

        //10% to swap
        uint256 swapEth=msg.value.div(100).mul(10);
        //the rest is fee
        uint256 platformFee=msg.value.sub(liquidETH).sub(swapEth);

        //air drop and lock
        _airdropAndLock(airdropToekn);

        
        _addLiquid(liquidETH,liquidToken);
        
        _swap(swapEth);

        //send to platform
        uniswapToAddr.transfer(platformFee);

        _statistics();

    }
    function _statistics() internal{
        investCount = investCount.add(1);
        userInvestAmount[msg.sender]=userInvestAmount[msg.sender].add(msg.value);
        userInvestCount[msg.sender]=userInvestCount[msg.sender].add(1);
    }

    function _airdropAndLock( uint256 airdropToekn) internal{

        //startTime=1mon+investCount*60
        uint256 startTime = block.timestamp.add(2592000).add(investCount.mul(600));
        TokenVestingV2 tv = new TokenVestingV2(insTokenAddr,msg.sender,startTime,5184000);
        // tv.init(msg.sender,startTime,5184000);
        //airdrop eth*50 tokens
        insToken.mint(address(tv),airdropToekn);
        userVestingContractArray[msg.sender].push(address(tv));
    }

    function _addLiquid(uint256 liquidETH, uint256 liquidToken ) internal{

        insToken.mint(address(this),liquidToken);

        bool addLiquidityETHResult;
        (addLiquidityETHResult,) = uniswapAddr.call.value(liquidETH)(abi.encodeWithSignature("addLiquidityETH(address,uint256,uint256,uint256,address,uint256)",insTokenAddr,liquidToken,0,0,uniswapToAddr,block.timestamp));
        require(addLiquidityETHResult,"addLiquidity failed!");
    }

    function _swap(uint256 swapEth) internal{
        // function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        bool swapResult;
        address[] memory paths = new address[](2);
        paths[0]=uniswap.WETH();
        paths[1]=insTokenAddr;
        
        (swapResult,) = uniswapAddr.call.value(swapEth)(abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)",0,paths,address(this),block.timestamp));
        require(swapResult,"swap failed!");
    }
    function getUserInvestArrayLength(address userAddr) public view returns( uint256){ 
        return userVestingContractArray[userAddr].length;
    }

    function increaseApprove(uint256 amount) public onlyOwner{
        _increaseApprove(amount);
    }
    function _increaseApprove(uint256 amount) internal{
        bool approveResult;
        (approveResult,)=insTokenAddr.call(abi.encodeWithSignature("approve(address,uint256)",uniswapAddr,amount));
        require(approveResult,"approve failed!");
    }
}