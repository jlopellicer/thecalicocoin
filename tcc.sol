// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Safe ERC20 and BEP20 Token
/// @author Jorge López Pellicer
/// @dev https://www.linkedin.com/in/jorge-lopez-pellicer/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheCalicoToken is ERC20, Ownable {
    uint8 private constant _decimals = 10;
    uint256 private constant _initialSupply = 10_000_000_000 * (10 ** _decimals);

    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Stake) private _stakes;
    uint256 private constant REWARD_RATE = 10;
    uint256 private constant SECONDS_IN_YEAR = 365 * 24 * 60 * 60;

    constructor(address initialOwner) ERC20("TheCalicoCoin", "TCC") Ownable(initialOwner) {
        _mint(address(this), _initialSupply);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    // --- STAKING ---
    function stakeTokens(uint256 amount) external {
        require(amount > 0, "You cannot stake 0 tokens");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");

        _transfer(msg.sender, address(this), amount);
        _stakes[msg.sender] = Stake(amount, block.timestamp);
    }

    function unstakeTokens() external {
        Stake memory userStake = _stakes[msg.sender];
        require(userStake.amount > 0, "You have no tokens being staked");

        uint256 stakingDuration = block.timestamp - userStake.startTime;
        uint256 reward = (userStake.amount * REWARD_RATE * stakingDuration) / (100 * SECONDS_IN_YEAR);
        uint256 totalAmount = userStake.amount + reward;

        _stakes[msg.sender] = Stake(0, 0);
        _mint(msg.sender, reward);
        _transfer(address(this), msg.sender, userStake.amount);
    }

    function getStakeInfo(address user) external view returns (uint256 amount, uint256 startTime) {
        Stake memory userStake = _stakes[user];
        return (userStake.amount, userStake.startTime);
    }

    // --- PRESALE ---
    mapping(address => uint256) public contributions;
    uint256 public constant HARDCAP = 15 ether;
    uint256 public totalRaised;
    bool public presaleEnded = false;

    function invest() external payable {
        require(!presaleEnded, "Presale already completed!");
        require(totalRaised + msg.value <= HARDCAP, "Hardcap already completed");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function exitInvesting() external payable {
        uint256 userInvestment = contributions[msg.sender];
        require(userInvestment > 0, "No investment found for user");
        payable(msg.sender).transfer(userInvestment);
        contributions[msg.sender] -= userInvestment;
        totalRaised -= userInvestment;
    }

    function endPresale() external onlyOwner {
        require(!presaleEnded, "Presale already completed!");
        presaleEnded = true;
        _transfer(address(this), owner(), liquidityAmount);
    }

    function claimTokens() external {
        require(presaleEnded, "Presale not completed yet");
        uint256 amount = (contributions[msg.sender] * _initialSupply) / totalRaised;
        contributions[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount);
    }
}

