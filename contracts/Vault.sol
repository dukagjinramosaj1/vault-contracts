// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Vault is
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    mapping(address => uint256) private balances;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private rewardDebt;
    uint256 private accRewardPerShare; // Accumulated reward per share, scaled by 1e12
    uint256 private totalDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);
    }

    receive() external payable {
        // Update accRewardPerShare when receiving rewards from AdminVault
        if (totalDeposits > 0) {
            accRewardPerShare += (msg.value * 1e12) / totalDeposits;
            emit RewardsDistributed(msg.value);
        }
    }

    fallback() external payable {}

    // Allows a user to deposit Ether into the vault
    function deposit() external payable nonReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        _updateRewards(msg.sender);

        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Allows a user to withdraw their deposited Ether from the vault
    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        _updateRewards(msg.sender);

        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Returns the balance of a specific user
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // Allows a user to claim their accumulated rewards
    function claimRewards() external nonReentrant {
        _updateRewards(msg.sender);

        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards available");

        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
        emit RewardsClaimed(msg.sender, reward);
    }

    // Updates the rewards for a specific user
    function _updateRewards(address user) internal {
        if (balances[user] > 0) {
            uint256 pending = (balances[user] * accRewardPerShare) /
                1e12 -
                rewardDebt[user];
            rewards[user] += pending;
        }
        rewardDebt[user] = (balances[user] * accRewardPerShare) / 1e12;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControlUpgradeable) returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId);
    }
}
