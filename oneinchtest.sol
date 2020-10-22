pragma solidity ^0.6.6;

import { IOneSplit } from "../contracts/interfaces/IOneSplit.sol"; 
import "./interfaces/IERC20.sol";

contract oneinchtest {
    event LogBuy(address sellAddr, address buyAddr, uint256 sellAmount, uint256 buyAmount);
    event input_sc(uint256 amountWei, uint256 returnAmount, uint256[] distribution);

    address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public constant sUSD = address(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);

    address public constant ETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    address public constant OneInchAddress = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;

    mapping (int128 => address) curve_addresses;
    mapping (int128 => address) addresses;

    IOneSplit public oneinch;

    constructor() public {
        curve_addresses[0] = DAI;
        curve_addresses[1] = USDC;
        curve_addresses[2] = USDT;
        curve_addresses[3] = sUSD;

        addresses[0] = ETH;

        oneinch = IOneSplit(OneInchAddress);
    }

    function getExpectedReturn(uint256 amountWei) public view returns(uint256 returnAmount, uint256[] memory distribution) {
        IERC20 _from = IERC20(curve_addresses[0]);
        IERC20 _to = IERC20(curve_addresses[1]);

        (uint256 returnAmount, uint256[] memory distribution) = oneinch.getExpectedReturn(_from, _to, amountWei, 10, 0);

        return (returnAmount, distribution);
    }

    function oneinchswap(uint256 amountWei, uint256 returnAmount, uint256[] memory distribution) public payable {
        IERC20 _from = IERC20(curve_addresses[0]);
        IERC20 _to = IERC20(curve_addresses[1]);

        _from.approve(OneInchAddress, amountWei);

        // (uint256 returnAmount, uint256[] memory distribution) = oneinch.getExpectedReturn(_from, _to, amountWei, 10, 0);
        
        emit input_sc(amountWei, returnAmount, distribution);

        oneinch.swap(
            _from,
            _to,
            amountWei,
            returnAmount,
            distribution,
            0
        );

        emit LogBuy(curve_addresses[0], curve_addresses[1], amountWei, returnAmount);
    }
}
