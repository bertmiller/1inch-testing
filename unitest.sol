pragma solidity ^0.6.6;

import '@uniswap/v2-periphery/contracts/UniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

import "@studydefi/money-legos/curvefi/contracts/ICurveFiCurve.sol";
/* import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; */

contract UniTest {

  IUniswapV2Router02 public USRouter;
  ICurveFiCurve public curve;
  IERC20 public dai;

  address constant curveFi_curve_cDai_cUsdc = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
  address usdc_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address dai_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  /* These are needed to trade stablecoins on Curve */
  int128 constant daiIndex = 0;
  int128 constant usdcIndex = 1;

  /* Best practice is to do this dynamically but I'll get to that later */
  constructor() public {
    USRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D );
    curve = ICurveFiCurve(curveFi_curve_cDai_cUsdc);
    dai = IERC20(dai_address);
  }

  function uniTest(uint amount, address token) public payable {
    /* Create instances of DAI and USDC to interact with */
    IERC20 usdc = IERC20(usdc_address);

    /* Perform swap on UniSwap */
    convertETHToToken(amount, token, address(this));

    /* Get the balance of the resulting DAI */
    uint256 daiBal = dai.balanceOf(address(this));

    require(daiBal > 0, "No dai to trade.");

    /* Swap it for USDC on Curve */
    curveSwap(daiIndex, usdcIndex, daiBal);

    /* uint256 usdcBal = usdc.balanceOf(address(this)); */
    /* usdc.transfer(msg.sender, usdcBal); */
  }

  function convertETHToToken(uint amount, address token, address to) public payable {
    // Inputs //
    // amount: amount of token (note that the token may have many decimals)
    // token: address of the desired token
    // to: address to payout the result of the swap to

    // Output: performs a swap for that amount of token and returns excess ETH

    // Allotted time to fill the trade
    uint deadline = block.timestamp + 15;

    // Specifies the path to trade for multi-step trades. Here we're just going from ETH to our token
    address[] memory path = new address[](2);
    path[0] = USRouter.WETH(); //This tells Uniswap to use ETH
    path[1] = token;

    // Perform the swap
    USRouter.swapETHForExactTokens{value: msg.value}(amount, path, to, deadline);

    // Return any leftover ETH
    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "refund failed");

    // Creates an instance of DAI
    IERC20 dai = IERC20(dai_address);
    // Gets the DAI balance of the smart contract after the swap
    uint256 daiBal = dai.balanceOf(address(this));

    // Transfers the balance to "to", which in this case, is the smart contract.
    dai.transfer(to, daiBal);
  }

  function curveSwap(int128 from, int128 to, uint256 amount) public payable {
    /* Check the amount of the stable coin you'd get */
    uint min_bal = getSwapInfo(from, to, amount);

    /* Revert if that is 0*/
    require(min_bal >= 1, "minimum not exceeded");

    /* Approve that DAI for trading */
    require(dai.approve(address(curve), amount), "Approve failed.");

    /* Perform a swap on Curve */
    curve.exchange_underlying(from, to, amount, 1);
  }

  receive() payable external {} // allows it to take ETH
}
