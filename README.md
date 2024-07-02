# Vault Contract 

![diagram-export-09-06-2024-20_25_18](https://github.com/dukagjinramosaj1/fractality_task/assets/29499894/3a0b1f16-9ed9-4cde-9474-f83272a7c11f)

# AdminVault and Vault Contracts

The **AdminVault** and **Vault** contracts serve distinct purposes within the system, separating user interactions from administrative actions for better security, maintainability, and modularity. Here’s the rationale behind having both:

## Separation of Concerns

### Vault.sol
- **User Interactions:** The Vault contract handles all interactions with end users, such as deposits, withdrawals, balance inquiries, and reward claims.
- **Security:** By isolating user functions, the Vault ensures that user operations are straightforward and secure, reducing the attack surface.

### AdminVault.sol
- **Administrative Actions:** The AdminVault contract is responsible for administrative tasks like distributing rewards, deploying funds to external strategies, and pulling funds back.
- **Access Control:** It uses a multi-signature wallet for admin actions to enhance security. By separating these actions from user functions, it minimizes the risk of unauthorized access or misuse of administrative privileges.

## Security and Access Control

- **Role-based Access:** Separating administrative and user functions into different contracts allows for more granular access control. The AdminVault can be restricted to specific admin roles, while the Vault remains accessible to all users.
- **Multi-signature Wallet:** Administrative actions typically involve higher risks. Using a multi-signature wallet in AdminVault ensures that no single admin can execute critical functions without consensus from other admins. Here we can define the threshhold of accounts defining the number of signatures for a transaction to be executed.

## Maintainability and Modularity

- **Code Clarity:** By separating concerns, the contracts remain smaller and more focused, making them easier to understand, audit, and maintain.
- **Upgradeable and Extensible:** Future updates or enhancements can be applied more easily. For example, new strategies or reward distribution mechanisms can be added to AdminVault without affecting user-related code in Vault.

## Operational Efficiency

- **Scheduled Tasks:** The AdminVault can be extended to handle scheduled tasks such as daily reward distribution without involving user-specific code. This separation ensures that user interactions are not disrupted by administrative processes.
- **Automated Processes:** Admin tasks like fund deployment and reward distribution can be automated and managed separately, improving overall system efficiency.

## Example Scenario

Here’s an example to illustrate how the two contracts work together:

- **User Deposits and Withdrawals:** Users interact with the Vault contract to deposit or withdraw funds. Their balances are managed within the Vault.
- **Reward Distribution:** Admins use the AdminVault to distribute rewards to users. The AdminVault calculates rewards and sends them to the Vault, where users can claim them.
- **Fund Management:** Admins deploy funds from the Vault to external strategies through the AdminVault. This deployment is secured by the multi-signature process, ensuring that multiple admins approve the transaction.



# From planning to execution

## Step 1: Define Requirements and Specifications

### User Interactions:
- Deposit funds
- Withdraw funds
- View balance
- Claim or compound rewards

### Admin Interactions:
- Distribute rewards
- Deploy funds to external strategies
- Pull funds from external strategies

### Security Requirements:
- Protect user funds from malicious attacks
- Secure admin operations with multi-sig wallet
- Monitor and prevent unauthorized transactions

## Step 2: Design Interfaces and Flow Diagrams
### Interfaces:
- `IVault`: Interface for user interactions with the vault
- `IAdminVault`: Interface for admin interactions
- `IStrategy`: Interface for external strategy interactions
### Flow Diagrams:
- User deposit/withdraw process
- Admin reward distribution and fund deployment process
- Multi-sig transaction approval process

## Step 3: Define Smart Contracts and Functions

### Vault Contract (`Vault.sol`):
- **Functions**: 
  - `deposit()`
  - `withdraw()`
  - `getBalance()`
  - `claimRewards()`
  - `compoundRewards()`
- **Events**: 
  - `Deposit`
  - `Withdraw`
  - `RewardsClaimed`
  - `RewardsCompounded`

### AdminVault Contract (`AdminVault.sol`):
- **Functions**: 
  - `distributeRewards()`
  - `deployFunds()`
  - `pullFunds()`
- **Events**: 
  - `RewardsDistributed`
  - `FundsDeployed`
  - `FundsPulled`
- **Multi-sig functions**: 
  - `submitTransaction()`
  - `confirmTransaction()`
  - `executeTransaction()`

### Strategy Contract (`Strategy.sol`):
- **Functions**: 
  - `invest()`
  - `withdrawInvestment()`
  - `getReturns()`
- **Events**: 
  - `InvestmentMade`
  - `InvestmentWithdrawn`
  - `ReturnsReported`

## Step 4 Security Measures

### Access Control:
- Use OpenZeppelin’s `AccessControl` for role-based access
### Reentrancy Guard:
- Use OpenZeppelin’s `ReentrancyGuard` to prevent reentrancy attacks

### Upgradable Contracts:
- Use OpenZeppelin’s `Upgradable Contracts` to enable contract upgradability in case of future developments, bug fixes.

### Input Validation:
- Validate user inputs to prevent attacks such as integer overflow/underflow

### Unit Tests:
- Test all functions with various scenarios to ensure robustness


## Step 5: Sample Pseudo-Code and Repository Structure
This repo contains sample pseudo code and repo structure for continue development. It is a Hardhat project, where the smart contracts are created using Solidity and testing framework such as jest and mocha. 



# Project Setup - Local 

This project illustrates a basic concept and boilerplate code for the task.

Install dependencies
  - `npm install --legacy-peer-deps`


To deploy smart contracts locally run: 
  - `npx hardhat run script/deploy.ts --network hardhat`
  
To run tests 
  - `npx hardhat tests` 
