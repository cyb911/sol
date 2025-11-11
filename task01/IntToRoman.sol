// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntToRoman {
    function intToRoman(uint256 num) external pure returns (string memory) {
        require(num > 0 && num < 4000, unicode"非法范围（1-3999）");

        uint16[13] memory values = [1000,900,500,400,100,90,50,40,10,9,5,4,1];
        bytes[13] memory symbols = [bytes("M"),bytes("CM"),bytes("D"),bytes("CD"),bytes("C"),bytes("XC"),bytes("L"),bytes("XL"),
            bytes("X"),bytes("IX"),bytes("V"),bytes("IV"),bytes("I")];
        
        // 一次性分配好内存空间，罗马数字最长15
        bytes memory result = new bytes(15);

        // 记录字节数组实际的内存位置
        uint256 t = 0;

        for (uint256 i = 0; i < values.length;) {
            while (num >= values[i]) {
                // 将当前罗马字符 复制进result内存位置中去
                bytes memory tempSymbols = symbols[i];
                for (uint256 j = 0; j < tempSymbols.length;) {
                    result[t] = tempSymbols[j];
                    unchecked { //关闭整形溢出检查
                        j++; t++;
                    }
                }
                unchecked { num -= values[i]; }
            }
            unchecked { i++; }
        }
        // 内存空间进行截取
        assembly {
            mstore(result,t)
        }
        return string(result);
    }
}