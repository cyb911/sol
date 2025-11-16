// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721Metadata} from "./IERC721Metadata.sol";
import {IERC165} from "./IERC165.sol";
import {IERC721} from "./IERC721.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol"; // 只导入不适用

abstract contract ERC721 is IERC165,IERC721Metadata {
    string private _name;// NFT 名称

    string private _symbol;// NFT 符号

    // tokenId => 拥有者
    mapping(uint256 => address) private _owners;

    // 拥有者地址 => 拥有的 NFT 数量
    mapping(address => uint256) private _balances;

    // tokenId => 单独授权的地址
    mapping(uint256 => address) private _tokenApprovals;

    // 拥有者 => (操作员 => 是否授权)
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // tokenId => tokenURI
    mapping(uint256 => string) private _tokenURIs;

    // 自增的 tokenId 计数器
    uint256 private _nextTokenId;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    

    //==========ERC165==========
    // 本合约支持哪些接口
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            // IERC721
            interfaceId == type(IERC721).interfaceId ||
            // IERC721Metadata
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    //==========ERC721Metadata 实现==========
    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    // 返回某个 tokenId 的元数据（如 IPFS 链接）
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    //==========ERC721 实现==========
    // 返回地址 owner 拥有的 NFT 数量
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    // 返回 tokenId 的拥有者
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    // 授权某个 address 可以操作该 tokenId
    function approve(address to, uint256 tokenId) external override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }
    // 查询 tokenId 的被授权地址
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    // 批量授权某个 operator 管理 msg.sender 的所有 NFT
    function setApprovalForAll(address operator, bool approved) external override {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询 operator 是否被 owner 授权
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    // 普通 transfer（可能丢失 NFT 到合约）
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

    // safeTransfer：多了接收合约回调，避免 NFT 被锁死
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    

    

    //========内部函数=======
    // 设置 tokenURI
    function _setTokenURI(uint256 tokenId, string memory tokenURI_) internal {
        require(_exists(tokenId), "ERC721: URI set of nonexistent token");
        _tokenURIs[tokenId] = tokenURI_;
    }

    // 检查 tokenId 是否存在
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // 内部授权
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    // 判断 address 是否为 owner / 单独授权 / 批量授权者
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId); // 已经检查存在性
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // 交易
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // 清除单独授权
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // safeTransfer：检查接收者是否是合约，并调用 onERC721Received
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(msg.sender, from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer");
    }

    // 检查目标是否为合约，并尝试调用 onERC721Received
    function _checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (_isContract(to)) {
            try IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            // 目标是外部账户（EOA），直接返回 true
            return true;
        }
    }
    

    // 判断地址是否是合约
    function _isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }

    // 铸造NFT行为
    function _mint(address to, uint256 tokenId) internal {
        require(!_exists(tokenId), "ERC721: token already minted");
        require(to != address(0), "ERC721: mint to the zero address");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
}