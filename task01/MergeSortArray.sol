// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortArray {
    function merge(uint256[] calldata arr1, uint256[] calldata arr2) external pure returns (uint256[] memory) {
        uint256 n1 = arr1.length;
        uint256 n2 = arr2.length;
        // 定义一个动态数组，用于存放合并后得元素
        uint256[] memory mergeArr = new uint256[](n1 + n2);

        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;

        // 双指针合并
        while (i < n1 && j < n2) {
            if (arr1[i] < arr2[j]) {
                mergeArr[k] = arr1[i];
                unchecked {i++;}
            } else {
                mergeArr[k] = arr2[j];
                unchecked {j++;}
            }
            k++;
        }

        // copy剩余得数据元素到合并数组中
        while (i < n1) {
            mergeArr[k] = arr1[i];
            unchecked {i++;}
            unchecked {k++;}
        }

        while (j < n2) {
            mergeArr[k] = arr2[j];
            unchecked {j++;}
            unchecked {k++;}
        }

        return mergeArr;

    }
}