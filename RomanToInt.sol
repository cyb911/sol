// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract RomanToInt {
    // 编译期，确定罗马字母对应的 8bit字节值
    bytes1 constant I = bytes1("I");
    bytes1 constant V = bytes1("V");
    bytes1 constant X = bytes1("X");
    bytes1 constant L = bytes1("L");
    bytes1 constant C = bytes1("C");
    bytes1 constant D = bytes1("D");
    bytes1 constant M = bytes1("M");

    function romanToInt(string calldata input) external pure returns (uint256) {
        bytes memory chars = bytes(input);

        uint256 length = chars.length;
        require(length > 0, unicode"输入的是空字符串");

        /**
        * 罗马数字规则：
        * 1. I, X, C, M 可以连续出现但最多 3 次。
        * 2. V, L, D 不能重复。
        * 3. I 只能放在 V 或 X 左边表示减法。
        * 4. X 只能放在 L 或 C 左边表示减法。
        * 5. C 只能放在 D 或 M 左边表示减法。
        * 6. 遍历时如果当前字符对应的值 < 右侧字符的值，则做减法，否则加法。
        */

        bytes1 preCh; // 上一个字符
        uint8 re = 0;
        uint256 preV = 0;
        uint256 total = 0;

        for (uint256 index = length; index > 0;) {
            unchecked {
                index--;
            }
            bytes1 ch = chars[index];
            uint value = ramBytes2Uint256(ch);
            require(value != 0, unicode"存在非法字符（仅支持 I,V,X,L,C,D,M）");
            
            // 规则校验
            if (ch == preCh) {
                re++;
                require(ch != V && ch != L && ch != D, unicode"V/L/D 不可重复");
                require(re < 3, unicode"同字符连续超过3次");
            } else {
                re = 0;
            }

            if(value < preV) {
                bool ok = isValid(ch,preCh);
                require(ok, unicode"非法的罗马数字");
                unchecked {
                    total -= value;
                }
            } else {
                unchecked {
                    total += value;
                    preV = value;
                }
            }

            preCh = ch;
        }

        return total;
    }

    function isValid(bytes1 left,bytes1 right) private pure returns (bool) {
        if (left == I) return right == V || right == X;
        if (left == X) return right == L || right == C;
        if (left == C) return right == D || right == M;
        return false;
    }

    

    function ramBytes2Uint256(bytes1 c) private pure returns (uint256) {
        if (c == I) return 1;
        if (c == V) return 5;
        if (c == X) return 10;
        if (c == L) return 50;
        if (c == C) return 100;
        if (c == D) return 500;
        if (c == M) return 1000;
        return 0;
    }
}