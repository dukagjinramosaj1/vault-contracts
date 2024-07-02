import { expect } from "chai";
import { ethers } from "hardhat";
import { AdminVault, Vault, AdminVault__factory, Vault__factory } from "../typechain-types";

describe("AdminVault", function () {
    let adminVault: AdminVault;
    let vault: Vault;
    let deployer, addr1;

    beforeEach(async function () {
        [deployer, addr1] = await ethers.getSigners();

        const Vault = await ethers.getContractFactory("Vault");
        vault = await Vault.deploy();
        await vault.deployed();

        const AdminVault = await ethers.getContractFactory("AdminVault");
        adminVault = await AdminVault.deploy();
        await adminVault.initialize(vault.address);
    });

    describe("Deployment", function () {
        it("Should set the right roles", async function () {
            expect(await adminVault.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("PAUSER_ROLE")), deployer.address)).to.be.true;
            expect(await adminVault.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("UPGRADER_ROLE")), deployer.address)).to.be.true;
        });
    });

    describe("Distribute Rewards", function () {
        it("should revert if there are no rewards to distribute", async function () {
            await expect(adminVault.distributeRewards()).to.be.revertedWith("NoRewardsToDistribute");
        });

        it("should distribute rewards successfully", async function () {
            const sendValue = { value: ethers.utils.parseEther("1.0") };
            await deployer.sendTransaction({ to: adminVault.address, ...sendValue });

            await expect(adminVault.distributeRewards()).to.emit(adminVault, "RewardsDistributed").withArgs(ethers.utils.parseEther("1.0"));
        });
    });

    describe("Deploy Funds", function () {
        it("should revert if trying to deploy more funds than available", async function () {
            await expect(adminVault.deployFunds(addr1.address, ethers.utils.parseEther("1.0"))).to.be.revertedWith("InsufficientFunds");
        });

        it("should deploy funds successfully", async function () {
            const sendValue = { value: ethers.utils.parseEther("1.0") };
            await deployer.sendTransaction({ to: adminVault.address, ...sendValue });

            await expect(adminVault.deployFunds(addr1.address, ethers.utils.parseEther("0.5"))).to.emit(adminVault, "FundsDeployed").withArgs(addr1.address, ethers.utils.parseEther("0.5"));
        });
    });

    describe("Pull Funds", function () {
        it("should emit FundsPulled event", async function () {
            await expect(adminVault.pullFunds(addr1.address, ethers.utils.parseEther("0.5"))).to.emit(adminVault, "FundsPulled").withArgs(addr1.address, ethers.utils.parseEther("0.5"));
        });
    });

    describe("Authorization for Upgrade", function () {
        it("should only allow admin to authorize upgrades", async function () {
            await expect(adminVault.connect(addr1).initialize(addr1.address)).to.be.reverted;
        });
    });
});