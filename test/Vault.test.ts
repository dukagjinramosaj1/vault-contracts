import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Vault, Vault__factory } from "../typechain-types";

describe("Vault", function () {
  let vault: Vault;
  let owner: any, addr1: any, addr2: any;

  beforeEach(async function () {
    const Vault = await ethers.getContractFactory("Vault");
    vault = (await upgrades.deployProxy(Vault, [], { initializer: 'initialize' })) as unknown as Vault;
    await vault.deployed();

    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("Should set the right roles", async function () {
      expect(await vault.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("PAUSER_ROLE")), owner.address)).to.be.true;
      expect(await vault.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("UPGRADER_ROLE")), owner.address)).to.be.true;
    });
  });

  describe("Deposit", function () {
    it("should allow users to deposit ether", async function () {
      const depositAmount = ethers.utils.parseEther("1");
      await vault.connect(addr1).deposit({ value: depositAmount });
      expect((await vault.getBalance(addr1.address)).toString()).to.equal('1000000000000000000');
    });
  });

  describe("Withdraw", function () {
    it("should allow users to withdraw ether", async function () {
      const depositAmount = ethers.utils.parseEther("1");
      await vault.connect(addr1).deposit({ value: depositAmount });

      const withdrawAmount = ethers.utils.parseEther("0.5");
      await vault.connect(addr1).withdraw(withdrawAmount);

      const finalBalance = await vault.getBalance(addr1.address);
      expect(finalBalance.toString()).to.equal(depositAmount.sub(withdrawAmount).toString());
    });
  });

  describe("Rewards", function () {
    beforeEach(async function () {
      await vault.connect(addr1).deposit({ value: ethers.utils.parseEther("2.0") });
      await vault.connect(addr2).deposit({ value: ethers.utils.parseEther("1.0") });
      await owner.sendTransaction({
        to: vault.address,
        value: ethers.utils.parseEther("3.0"), // Simulating rewards sent from AdminVault
      });
    });

    it("Should update rewards correctly", async function () {
      await vault.connect(addr1).claimRewards();
      await vault.connect(addr2).claimRewards();
      expect((await vault.getBalance(addr1.address)).toString()).to.equal('2000000000000000000');
      expect((await vault.getBalance(addr2.address)).toString()).to.equal('1000000000000000000');
    });

    it("Should emit a RewardsClaimed event", async function () {
        await expect(vault.connect(addr1).claimRewards())
        .to.emit(vault, "RewardsClaimed")
        .withArgs(addr1.address, '2000000000000000000');
    });


    it("Should revert if no rewards are available", async function () {
      await vault.connect(addr1).claimRewards(); // First claim
      await expect(vault.connect(addr1).claimRewards()).to.be.revertedWith("No rewards available");
    });
  });
});