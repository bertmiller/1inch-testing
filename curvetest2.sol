pragma solidity ^0.6.6;

import "@studydefi/money-legos/curvefi/contracts/ICurveFiCurve.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract curvetest {
    ICurveFiCurve public curve;

    address constant curveFi_curve_cDai_cUsdc = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
    address dai_address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    /* Best practice is to do this dynamically but I'll get to that later */
    constructor() public {
        /* Create an instance of the Curve Pool we want */
        curve = ICurveFiCurve(curveFi_curve_cDai_cUsdc);
    }

    function getSwapInfo(int128 from, int128 to, uint256 amount) public returns (uint) {
        return curve.get_dy_underlying(from, to, amount);
    }

    function _curveSwap(int128 from, int128 to, uint256 amount) public {
        IERC20 dai = IERC20(dai_address);
        uint256 daiBal = dai.balanceOf(address(this));
        require(dai.approve(curveFi_curve_cDai_cUsdc, daiBal + 1), "approve failed");

        curve.exchange_underlying(from, to, daiBal, 1);
    }


}
