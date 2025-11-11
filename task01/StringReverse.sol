// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract StringReverse { 
    function reverse(string calldata str) external pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint256 len = strBytes.length;
        // 字符串只包含一个字符的时候，直接原值返回，避免gas费消耗
        if (len == 1) {
            return str;
        }
        bytes memory reversed = new bytes(len);

        uint256 i = 0;
        uint256 j = len;

        unchecked {// 关闭溢出检查，这段逻辑无溢出问题存在
            while (i < len) {
                reversed[i++] = strBytes[--j]; // 双指针法
            }
        }

        return string(reversed);

    }
}