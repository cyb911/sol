// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Errors {
    // 发送者地址无效
    error ERC20InvalidSender(address sender);

    // 接收方地址无效
    error ERC20InvalidReceiver(address receiver);
    // 余额不足
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address approver);

    // 授权额度不足
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
}