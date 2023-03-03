// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {


    const addrOwner = '0x0d5FdE8D013F3139CCE77d91Cd1346434b173311'

    const AuthorizationControl = await hre.ethers.getContractFactory('AuthorizationControl');
    const authorizationControl = await AuthorizationControl.deploy(addrOwner)

    await authorizationControl.deployed();

    console.log("Contract AuthorizationControl deployed to:", authorizationControl.address)


    const AccessControlTest = await hre.ethers.getContractFactory('AccessControlTest');
    const accessControlTest = await AccessControlTest.deploy(authorizationControl.address)

    await accessControlTest.deployed();


    console.log("Contract AccessControlTest deployed to:", accessControlTest.address)



    let role = ethers.utils.formatBytes32String('test_role')
    await authorizationControl.connect(addrOwner).saveRole(role, addrOwner);

    await accessControlTest.addPessoa("TESTE", 28)




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
