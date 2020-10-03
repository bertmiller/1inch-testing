pragma solidity ^0.6.6;

import '@uniswap/v2-periphery/contracts/UniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

import "@studydefi/money-legos/curvefi/contracts/ICurveFiCurve.sol";
/* import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; */

contract curveTest {
  address constant curveFi_curve_cDai_cUsdc = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
  address usdc_address = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address dai_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  function curveSwap(int128 from, int128 to, uint256 amount) public payable {
    /* Create an instance of DAI to interact with */
    IERC20 dai = IERC20(dai_address);

    /* Create an instance of the Curve Pool we want */
    ICurveFiCurve curve = ICurveFiCurve(curveFi_curve_cDai_cUsdc);

    /* Check the amount of the stable coin you'd get */
    uint min_bal = getSwapInfo(from, to, amount);

    /* Revert if that is 0*/
    require(min_bal >= 1, "minimum not exceeded");

    /* Approve that DAI for trading */
    require(dai.approve(address(curve), amount), "Approve failed.");

    /* Perform a swap on Curve */
    curve.exchange_underlying(from, to, amount, 1);
  }

  function getSwapInfo(int128 from, int128 to, uint256 amount) public returns (uint) {
      /* Create an instance of the Curve Pool we want */
      ICurveFiCurve curve = ICurveFiCurve(curveFi_curve_cDai_cUsdc);

      /* Return the amount you'd get in a swap. */
      return curve.get_dy_underlying(from, to, amount);
  }

  receive() payable external {} // allows it to take ETH
}
