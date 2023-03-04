const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("AccessControlTest", function () {

    async function deployContract() {

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        //const addrOwner = '0x0d5FdE8D013F3139CCE77d91Cd1346434b173311'

        console.log(owner.address)
        console.log(otherAccount.address)

        let master = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'  //owner.address;
        const AuthorizationControl = await hre.ethers.getContractFactory('AuthorizationControl');
        const authorizationControl = await AuthorizationControl.deploy(owner.address)

        await authorizationControl.deployed();

        console.log("Contract AuthorizationControl deployed to:", authorizationControl.address)



        const AccessControlTest = await hre.ethers.getContractFactory('AccessControlTest');
        const accessControlTest = await AccessControlTest.deploy(authorizationControl.address)

        await accessControlTest.deployed();


        console.log("Contract AccessControlTest deployed to:", accessControlTest.address)



        // let role = ethers.utils.formatBytes32String('test_role')
        //await authorizationControl.saveRole(role, owner);

        //await accessControlTest.addPessoa("TESTE", 28)
        return { accessControlTest, authorizationControl, owner, otherAccount }
    }

    describe("Deployment", function () {

        it("Check ROLE", async function () {

            // const { accessControlTest, ownerAddr } = await loadFixture(deployContract)


        });

    });



    describe("OnlyRole", function () {

        it("OnlyRole - ADD_ROLE ", async function () {

            const { accessControlTest, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)


            //await accessControlTest.addRoles(owner.address) 

            await authorizationControl.saveRole(ethers.utils.formatBytes32String("add_role"), otherAccount.address);

            await authorizationControl.saveRole(ethers.utils.formatBytes32String("update_role"), otherAccount.address);

            await accessControlTest.connect(otherAccount).addPessoa("TESTE", 28)

            await accessControlTest.connect(otherAccount).updateName(1, "TESTE SECURITY xxxxx")

            console.log(await accessControlTest.readPessoa(1))

        });




        it("OnlyRole - test_role ", async function () {

            /* const { accessControlTest, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)
 
             let role = ethers.utils.formatBytes32String("test_role")
             //await authorizationControl.connect(owner).saveRole(role, otherAccount.address);
 
 
 
             await expect(
 
                 accessControlTest.connect(otherAccount).addPessoa("TESTE", 28)
 
             ).to.be.revertedWithCustomError(authorizationControl, 'ROLES_RequireRole')*/






            //ROLES_RequireRole("0x746573745f726f6c650000000000000000000000000000000000000000000000")

            // console.log(await accessControlTest.readPessoa(1))

        });


    });






});