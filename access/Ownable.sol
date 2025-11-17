// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Ownable {
    address private _owner;

    // 没有权限
    error OwnableUnauthorizedAccount(address account);

    constructor(address initialOwner) {
        _owner = initialOwner;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}