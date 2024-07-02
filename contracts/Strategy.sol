// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Strategy is ReentrancyGuard {
    event InvestmentMade(address indexed investor, uint256 amount);
    event InvestmentWithdrawn(address indexed investor, uint256 amount);
    event ReturnsReported(uint256 returnsAmount);

    mapping(address => uint256) private _balances;

    function invest() external payable {
        require(msg.value > 0, "Investment amount must be greater than zero");
        _balances[msg.sender] += msg.value;
        emit InvestmentMade(msg.sender, msg.value);
    }

    function withdrawInvestment(uint256 amount) external nonReentrant {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit InvestmentWithdrawn(msg.sender, amount);
    }

    function getReturns(address investor) external view returns (uint256) {
        // Placeholder for actual returns calculation logic
        return (_balances[investor] * 10) / 100; // Example: 10% of the invested amount
    }

    // Additional function to allow contract to receive ETH
    receive() external payable {}
}
