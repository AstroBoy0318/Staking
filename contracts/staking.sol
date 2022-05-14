// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Staking {
    uint256 public Total = 0;
    uint256 public Sum = 0;
    mapping(address=>uint256) public stake;
    mapping(address=>uint256) public S0;
    IERC20 public token;
    uint256 public rewardPerSecond;
    uint256 public lastDistributeTime;
    constructor(IERC20 _token, uint256 _rewardPerSecond) {
        token = _token;
        rewardPerSecond = _rewardPerSecond;
    }

    function deposit(uint256 amount) external {
        stake[msg.sender] = stake[msg.sender] + amount;
        S0[msg.sender] = Sum;
        Total = Total + amount;

        token.transferFrom(msg.sender, address(this), amount);

        if(lastDistributeTime > 0) { 
            distribute((block.timestamp - lastDistributeTime)*rewardPerSecond);
        } else {
            lastDistributeTime = block.timestamp;
        }
    }

    function withdraw() external {
        uint256 unallocatedReward = (block.timestamp - lastDistributeTime)*rewardPerSecond;
        distribute(unallocatedReward);
        uint256 reward = getReward(msg.sender);
        token.transfer(msg.sender, reward);
        Total = Total - stake[msg.sender];
        stake[msg.sender] = 0;
    }

    function getReward(address account) public view returns(uint256) {
        uint256 unallocatedReward = (block.timestamp - lastDistributeTime)*rewardPerSecond;
        uint256 reward = stake[account] * (Sum + (unallocatedReward / Total) - S0[account]);
        return stake[account] + reward;
    }

    function distribute(uint256 reward) internal {
        if(Total != 0) {
            Sum = Sum + reward / Total;
            lastDistributeTime = block.timestamp;
        }
    }
}