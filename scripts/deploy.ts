import { ethers, upgrades } from "hardhat";



async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy the Vault contract
    const Vault = await ethers.getContractFactory("Vault");
    const vault = await upgrades.deployProxy(Vault, [], { initializer: "initialize", kind: 'uups' });
    await vault.deployed();
    console.log("Vault deployed to:", vault.address);



    // Deploy the AdminVault contract
    const AdminVault = await ethers.getContractFactory("AdminVault");
    const adminVault = await upgrades.deployProxy(AdminVault, [vault.address], { initializer: "initialize", kind: 'uups' });
    await adminVault.deployed();
    console.log("AdminVault deployed to:", adminVault.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });