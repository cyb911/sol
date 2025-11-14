// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 创建一个名为Voting的合约，包含以下功能： 
// 一个mapping来存储候选人的得票数 一个vote函数，允许用户投票给某个候选人 
// 一个getVotes函数，返回某个候选人的得票数 一个resetVotes函数，重置所有候选人的得票数
contract Vote {
    // 候选人票数
    mapping(address => uint256) private votes;

    // 候选人名单
    address[] private candidates;

    // 用于判断候选人在不在名单中
    mapping(address => bool) public isCandidate;

    // 记录地址投票轮数
    mapping (address=> uint256) private voteRound;

    // 合约当前投票轮数
    uint256 public currentRound = 1;

    // 部署者
    address public owner;

    constructor(address[] memory _candidate) {
        owner = msg.sender;
        for (uint256 i = 0; i < _candidate.length; i++) {
            address c = _candidate[i];
            require(!isCandidate[c], "duplicate");
            candidates.push(c);
            isCandidate[c] = true;
        }
    }

    // 获取候选人名单
    function getCandidates() external view  returns (address[] memory) {
        return candidates;
    }

    // 投票
    function voting(address candidate) external  {
        // 投的候选人是否存在
        require(isCandidate[candidate], "Candidate does not exist");
        require(voteRound[msg.sender] != currentRound, "You have already voted");
        votes[candidate] += 1;
        voteRound[msg.sender] = currentRound;
    }

    // 查询投票数
    function queryVoteCount(address candidate) external view returns(uint256) {
        require(isCandidate[candidate], "Candidate does not exist");
        return votes[candidate];
    }

    // 重置所有候选人的得票数
    function restVotes() external {
        require(msg.sender == owner, "Only owner can reset");
        for (uint i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }

        // Q:如何清除已投票地址
        // A:增加投票轮次

        currentRound++;
    }
}