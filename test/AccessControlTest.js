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

        //console.log(owner.address)
        //console.log(otherAccount.address)

        let master = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'  //owner.address;
        const AuthorizationControl = await hre.ethers.getContractFactory('AuthorizationControl')
        const authorizationControl = await AuthorizationControl.deploy(owner.address)

        await authorizationControl.deployed()


        const PessoasManager = await hre.ethers.getContractFactory('PessoasManager')
        const pessoasManager = await PessoasManager.deploy(authorizationControl.address)
        await pessoasManager.deployed()

        const AnimalManager = await hre.ethers.getContractFactory('AnimalManager')
        const animalManager = await AnimalManager.deploy(authorizationControl.address)
        await animalManager.deployed()

        return { animalManager, pessoasManager, authorizationControl, owner, otherAccount }
    }

    describe("Deployment", function () {

        it("Check ROLE", async function () {




        });

    });

    describe("OnlyRole", function () {

        it("OnlyRole - ADD_ROLE ", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)


            //await accessControlTest.addRoles(owner.address) 

            await authorizationControl.saveRole(ethers.utils.formatBytes32String("add_role"), otherAccount.address);

            await authorizationControl.saveRole(ethers.utils.formatBytes32String("update_role"), otherAccount.address);

            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)

            await pessoasManager.connect(otherAccount).updateName(1, "TESTE SECURITY xxxxx")

            //console.log(await accessControlTest.readPessoa(1))

        });

    });

    describe("OnlyRoleGroup", function () {

        it("OnlyRoleGroup - ADD_GROUP ", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)

            const roleDelete = ethers.utils.formatBytes32String("delete_role")
            const groupADM = ethers.utils.formatBytes32String("adm_group")
            const addRole = ethers.utils.formatBytes32String("add_role")

            await authorizationControl.saveRoleGroup(groupADM, roleDelete, otherAccount.address);

            await authorizationControl.saveRoleGroup(groupADM, addRole, otherAccount.address);  
            await authorizationControl.saveRole(addRole, otherAccount.address);

            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)

            await pessoasManager.connect(otherAccount).deletePessoa(1)

            await authorizationControl.removeRoleGroup(groupADM, roleDelete, otherAccount.address)

            //await accessControlTest.connect(otherAccount).deletePessoa(1)

            await expect(pessoasManager.connect(otherAccount).deletePessoa(1)).to.be.revertedWithCustomError(pessoasManager,
                'ROLES_RequireRoleGroup');

            await animalManager.connect(otherAccount).addAnimal("GLIMER", "GATO", 28)


            await expect(animalManager.connect(otherAccount).deleteAnimal(1)).to.be.revertedWithCustomError(animalManager,
                'ROLES_RequireRoleGroup');

        });

    });

    describe("getUsersByRole", function () {

        it("getUsersByRole", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)

            const roleDelete = ethers.utils.formatBytes32String("delete_role")

            const roleAdd = ethers.utils.formatBytes32String("add_role")

            await authorizationControl.saveRole(roleAdd, otherAccount.address)
            await authorizationControl.saveRole(roleDelete, otherAccount.address)
            await authorizationControl.saveRole(roleAdd, owner.address)

            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)

            const users1 = await authorizationControl.getUsersByRole(roleAdd)
            console.log(users1)
            await authorizationControl.removeRole(roleAdd, owner.address)
            const users2 = await authorizationControl.getUsersByRole(roleAdd)
            console.log(users2)

        });



        it("getUsersByRoleGroup", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)

            const deleteRole = ethers.utils.formatBytes32String("delete_role")
            const groupADM = ethers.utils.formatBytes32String("adm_group")
            const addRole = ethers.utils.formatBytes32String("add_role")

            await authorizationControl.saveRoleGroup(groupADM, deleteRole, otherAccount.address);
            await authorizationControl.saveRoleGroup(groupADM, deleteRole, owner.address);

            //await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)

            const users1 = await authorizationControl.getUsersByRoleGroup(groupADM, deleteRole)
            console.log(users1)
            await authorizationControl.removeRoleGroup(groupADM, deleteRole, otherAccount.address)
            const users2 = await authorizationControl.getUsersByRoleGroup(groupADM, deleteRole)
            console.log(users2)
            //remover novamente
            const addRolex = ethers.utils.formatBytes32String("123333")
            await authorizationControl.saveRoleGroup(groupADM, addRolex, otherAccount.address)

        });


    });

});
