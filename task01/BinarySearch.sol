// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 二分查找-在一个有序数组中查找目标值。
contract BinarySearch {
    function search(uint256[] calldata arr, uint256 target) external pure returns(bool found,uint256 index) {
        //require(msg.value > 0, unicode"存款金额必须大于0！");
        uint256 ln = arr.length;
        require(ln != 0,unicode"数组无效");

        uint256 left = 0; // 左指针
        uint256 right = arr.length - 1; //右指针

        

        while (left <= right) {
            // 找出数组中间边界元素
            uint256 mid = (right -left) / 2 + left;
            if (arr[mid] == target) {
                return (true,mid);
            } else if (target < arr[mid]) { // 在边界元素得左边
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        } 

        return (false,0);
    }
}