// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract SwapExample {
    // 创建 ISwapRouter 接口实例
    ISwapRouter public immutable swapRouter;
    
    // 要参与 swap 的 token 合约地址
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // 设置质押收益 0.3%
    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    // 输入确定的 swap
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender 必须批准这个合约

        // 发送确定数量的 DAI 到这个合约
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);

        // 批准 swapRouter 使用 DAI
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

        // 设置 swap 操作的参数
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // 调用 exactInputSingle 执行 swap
        amountOut = swapRouter.exactInputSingle(params);
    }
    
    // 输出确定的 swap
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // 向这个合约发送规定数量的 DAI
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountInMaximum);

        // 批准 swapRouter 使用 DAI
        TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

        // 设置 swap 操作的参数
        ISwapRouter.ExactOutputSingleParams memory params = 
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH9,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // 调用 exactOutputSingle 执行 swap
        amountIn = swapRouter.exactOutputSingle(params);

        // 提前规定的 DAI 可能不会全部消耗 
        // 如果有 DAI 剩余，退还给 msg.sender
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(DAI, address(this), 0);
            TransferHelper.safeTransfer(DAI, msg.sender, amountInMaximum - amountIn);
        }
    }
}