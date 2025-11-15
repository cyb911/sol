// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {IERC20Errors} from "./IERC20Errors.sol";

contract ERC20 is IERC20, IERC20Errors {

    // 代币名称
    string public name = "AmorLnkSmithToken";

    // 代币代码
    string public symbol = "AMLST";

    // 定义代币的最小单位
    uint8 public constant decimals = 18;

    // 合约持有者
    address public owner;


    // 总供应量，单位是AMLST 代币的最小单位
    uint256 private _totalSupply;

    // 账户余额
    mapping (address=> uint256) private _balances;

    // 授权额度
    mapping (address=> mapping(address => uint256)) private _allowances;

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        // initialSupply 按“整币”填，比如 1000，就是 1000 * 10^18
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    //========IERC20接口函数========

    // 余额查询
   function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
   }

   // 代币总发行量
   function totalSupply() external view returns (uint256) {
        return _totalSupply;
   }

    // 转账
   function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
   }

    // 授权
   function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
   }

   // 代扣转账
   function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
   }

   //=======合约特有函数========
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount * (10 ** uint256(decimals)));
    }


   //========内部函数========

   // 增发代币
   function _mint(address account, uint256 amount) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        // 发送者地址应该是0地址，表示是增发代币
        _update(address(0), account, amount);
    }

   function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    // 更新账户余额
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) { // 增发代币（mint）
            _totalSupply += value;
        } else { // 普通的扣款行为
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // 不可能存在溢出，关闭溢出检查
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) { // 销毁代币
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    // 授权
    function _approve(address _owner, address spender, uint256 value) internal {
        if (_owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }

        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }
    // 扣授权额度
    function _spendAllowance(address _owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = _allowance(_owner,spender);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(_owner, spender, currentAllowance - value);
            }
        }
    }

    // 获取授信额度（未来功能扩展，便于复用）
    function _allowance(address _owner,address spender) internal view virtual returns (uint256) {
        return _allowances[_owner][spender];
    }
}