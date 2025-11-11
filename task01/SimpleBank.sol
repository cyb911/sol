// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SimpleBank {
    // 保存每一个用户的余额
    mapping(address => uint256) private balance;

    // 定义存取日志
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, unicode"存款金额必须大于0！");

        balance[msg.sender] += msg.value;
        // 触发存款事件
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, unicode"取款金额必须大于0");
        require(balance[msg.sender] >= amount, unicode"余额不足！");

        balance[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balance[user];
    }
}