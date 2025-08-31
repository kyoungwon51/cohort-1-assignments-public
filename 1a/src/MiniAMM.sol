// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents {
    uint256 public k = 0;
    uint256 public xReserve = 0;
    uint256 public yReserve = 0;

    address public tokenX;
    address public tokenY;

    // implement constructor
    constructor(address _tokenX, address _tokenY) {
        require(_tokenX != address(0), "tokenX cannot be zero address");
        require(_tokenY != address(0), "tokenY cannot be zero address");
        require(_tokenX != _tokenY, "Tokens must be different");
        if (_tokenX < _tokenY) {
            tokenX = _tokenX;
            tokenY = _tokenY;
        } else {
            tokenX = _tokenY;
            tokenY = _tokenX;
        }
    }

    // add parameters and implement function.
    // this function will determine the initial 'k'.
    function _addLiquidityFirstTime() internal {}

    // add parameters and implement function.
    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime() internal {}

    // complete the function
    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external {
        require(xAmountIn > 0 && yAmountIn > 0, "Amounts must be greater than 0");
        if (k == 0) {
            // 최초 공급: 자유롭게 공급
            IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
            IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
            xReserve = xAmountIn;
            yReserve = yAmountIn;
            k = xReserve * yReserve;
        } else {
            // 이후 공급: 기존 비율 유지
            require(xReserve * yAmountIn == yReserve * xAmountIn, "Ratio must remain constant");
            IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
            IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
            xReserve += xAmountIn;
            yReserve += yAmountIn;
            k = xReserve * yReserve;
        }
        emit AddLiquidity(xAmountIn, yAmountIn);
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {
        require(xAmountIn > 0 || yAmountIn > 0, "Must swap at least one token");
        require(!(xAmountIn > 0 && yAmountIn > 0), "Can only swap one direction at a time");
        require(k > 0, "No liquidity in pool");
        if (xAmountIn > 0) {
            // x -> y
            if (xAmountIn >= xReserve) {
                revert("Insufficient liquidity");
            }
            if (xReserve + xAmountIn == 0) {
                revert("Insufficient liquidity");
            }
            IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
            uint256 newX = xReserve + xAmountIn;
            uint256 newY = k / newX;
            uint256 yOut = yReserve > newY ? yReserve - newY : 0;
            if (yOut == 0 || yOut > yReserve) {
                revert("Insufficient liquidity");
            }
            yReserve = newY;
            xReserve = newX;
            k = xReserve * yReserve;
            IERC20(tokenY).transfer(msg.sender, yOut);
            emit Swap(xAmountIn, yOut);
        } else {
            // y -> x
            if (yAmountIn >= yReserve) {
                revert("Insufficient liquidity");
            }
            if (yReserve + yAmountIn == 0) {
                revert("Insufficient liquidity");
            }
            IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
            uint256 newY = yReserve + yAmountIn;
            uint256 newX = k / newY;
            uint256 xOut = xReserve > newX ? xReserve - newX : 0;
            if (xOut == 0 || xOut > xReserve) {
                revert("Insufficient liquidity");
            }
            xReserve = newX;
            yReserve = newY;
            k = xReserve * yReserve;
            IERC20(tokenX).transfer(msg.sender, xOut);
            emit Swap(xOut, yAmountIn);
        }
    }
}
