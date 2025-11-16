// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    // 余额查询
   function balanceOf(address account) external view returns (uint256);
   
    // 代币总发行量
   function totalSupply() external view returns (uint256);

    // 转账
   function transfer(address to, uint256 value) external returns (bool);

    // 授权
   function approve(address spender, uint256 value) external returns (bool);

   // 代扣转账
   function transferFrom(address from, address to, uint256 value) external returns (bool);

    // 事件：转账
   event Transfer(address indexed from, address indexed to, uint256);
    // 事件：授权
   event Approval(address indexed owner,address indexed spender, uint256);
}

