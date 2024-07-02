// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./Vault.sol";

contract AdminVault is
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    using AddressUpgradeable for address payable;

    Vault private vault;
    address payable private vaultAddress;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // Custom errors for clearer error handling
    error NoRewardsToDistribute();
    error RewardsDistributionFailed();
    error InsufficientFunds();
    error FundDeploymentFailed();

    event RewardsDistributed(uint256 amount);
    event FundsDeployed(address strategy, uint256 amount);
    event FundsPulled(address strategy, uint256 amount);

    function initialize(address payable _vaultAddress) public initializer {
        __AccessControl_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Pausable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(UPGRADER_ROLE, msg.sender);

        vault = Vault(_vaultAddress);
        vaultAddress = _vaultAddress;
    }

    function distributeRewards()
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {
        uint256 rewards = address(this).balance;
        if (rewards == 0) revert NoRewardsToDistribute();

        vaultAddress.sendValue(rewards); // Using OpenZeppelin's safer sendValue

        emit RewardsDistributed(rewards);
    }

    function deployFunds(
        address strategy,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        if (amount > address(this).balance) revert InsufficientFunds();
        payable(strategy).sendValue(amount);
        emit FundsDeployed(strategy, amount);
    }

    function pullFunds(
        address strategy,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        emit FundsPulled(strategy, amount);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    receive() external payable {}

    fallback() external payable {}
}
