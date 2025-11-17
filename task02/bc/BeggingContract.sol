// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "../../access/Ownable.sol";
contract BeggingContract is Ownable {
   
    // 捐赠记录：捐赠者地址 => 累计捐赠金额（单位：wei）
    mapping(address => uint256) public donations;

    // 事件：收到捐赠
    event Donated(address indexed from, uint256 amount);

    // 事件：提取资金
    event Withdrawn(address indexed to, uint256 amount);

    // 构造函数：部署者即为合约所有者
    constructor() Ownable(msg.sender) {
    }


    /**
     * @dev 捐赠函数，允许用户向合约发送 ETH，并记录捐赠金额
     * 使用 payable 接收以太币
     */
    function donate() external payable {
        require(msg.value > 0, "No ETH sent");
        donations[msg.sender] += msg.value;
        emit Donated(msg.sender, msg.value);
    }

    /**
     * @dev 查询某个地址的捐赠金额
     */
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    /**
     * @dev 提取所有资金到 owner 地址
     * 仅合约拥有者可调用
     * 使用 address.transfer 实现提款
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        // 将合约内所有 ETH 转到 owner
        address ownerAddr = owner();
        payable(ownerAddr).transfer(balance);
        emit Withdrawn(ownerAddr, balance);
    }

    /**
     * @dev 可选：允许直接向合约转账（不调用 donate 时）
     * 也记录到 donations 中，调用者是 msg.sender
     */
    receive() external payable {
        require(msg.value > 0, "No ETH sent");
        donations[msg.sender] += msg.value;
        emit Donated(msg.sender, msg.value);
    }
}