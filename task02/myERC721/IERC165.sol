// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 确认一个合约是否支持某个接口。
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}