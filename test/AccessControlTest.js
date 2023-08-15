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

        let master = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'  //owner.address;
        const AuthorizationControl = await hre.ethers.getContractFactory('AuthorizationControl')
        const authorizationControl = await AuthorizationControl.deploy(owner.address)

        await authorizationControl.deployed()


        const AccessControl = await hre.ethers.getContractFactory('AccessControl')
        const accessControl = await AccessControl.deploy(authorizationControl.address)

        await accessControl.deployed()




        const PessoasManager = await hre.ethers.getContractFactory('PessoasManager')
        const pessoasManager = await PessoasManager.deploy(accessControl.address)
        await pessoasManager.deployed()

        const AnimalManager = await hre.ethers.getContractFactory('AnimalManager')
        const animalManager = await AnimalManager.deploy(accessControl.address)
        await animalManager.deployed()

        return { animalManager, pessoasManager, authorizationControl, owner, otherAccount , accessControl }
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

            //await authorizationControl.saveRole(ethers.utils.formatBytes32String("update_role"), otherAccount.address);

            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)


            await expect(pessoasManager.connect(otherAccount).updateName(1, "TESTE SECURITY xxxxx")).to.be.revertedWithCustomError(pessoasManager,
                'ROLES_RequireRole');

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

    describe("onlyMaster", function () {

        it("onlyMaster ", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount , accessControl } = await loadFixture(deployContract)

            await authorizationControl.saveRole(ethers.utils.formatBytes32String("add_role"), otherAccount.address);

            await expect(accessControl.connect(otherAccount).setAuthorizationControl(animalManager.address)).to.be.revertedWithCustomError(accessControl,
                'UNAUTHORIZED');

            //await pessoasManager.connect(owner).setAuthorizationControl(pessoasManager.address)

            await expect(
                accessControl.connect(owner).setAuthorizationControl(pessoasManager.address)
            ).to.be.revertedWith("AuthorizationControl address must be the same type IAuthorizationControl")

            await expect(
                accessControl.connect(owner).setAuthorizationControl(otherAccount.address)
            ).to.be.revertedWith("IAuthorizationControl address must be a contract")

            console.log("OLD")
            console.log(await pessoasManager.connect(owner).getAuthorizationControl())

            const AuthorizationControl = await hre.ethers.getContractFactory('AuthorizationControl')
            const authorizationControlNew = await AuthorizationControl.deploy(owner.address)

            await authorizationControlNew.deployed()

            console.log("NEW")

            console.log(authorizationControlNew.address)

            await accessControl.connect(owner).setAuthorizationControl(authorizationControlNew.address)

            const addrAuthPessoa = await pessoasManager.connect(owner).getAuthorizationControl()
            console.log(addrAuthPessoa)
            const addrAuthAnimal = await animalManager.connect(owner).getAuthorizationControl()
            console.log(addrAuthAnimal)

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
            //console.log(users1)
            await authorizationControl.removeRole(roleAdd, owner.address)
            const users2 = await authorizationControl.getUsersByRole(roleAdd)
            //console.log(users2)

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
            //console.log(users1)
            await authorizationControl.removeRoleGroup(groupADM, deleteRole, otherAccount.address)
            const users2 = await authorizationControl.getUsersByRoleGroup(groupADM, deleteRole)
            //console.log(users2)

            const addRolex = ethers.utils.formatBytes32String("123333")
            await expect(authorizationControl.saveRoleGroup(groupADM, addRolex, otherAccount.address)).to.be.revertedWithCustomError(authorizationControl,
                'InvalidName');

        });


    });

    describe("saveRole", function () {

        it("saveRole", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)
            const roleDelete = ethers.utils.formatBytes32String("delete_role")
            const roleAdd = ethers.utils.formatBytes32String("add_role")
            await authorizationControl.saveRole(roleAdd, otherAccount.address)
            await authorizationControl.saveRole(roleDelete, otherAccount.address)
            await authorizationControl.saveRole(roleAdd, owner.address)
            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)
            await authorizationControl.getUsersByRole(roleAdd)
        });


        it("saveRole - ROLES_AddressAlreadyHasRole", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)

            const roleAdd = ethers.utils.formatBytes32String("add_role")
            await authorizationControl.saveRole(roleAdd, otherAccount.address)
            await pessoasManager.connect(otherAccount).addPessoa("TESTE", 28)
            await expect(authorizationControl.saveRole(roleAdd, otherAccount.address)).to.be.revertedWithCustomError(authorizationControl,
                'ROLES_AddressAlreadyHasRole');
        });

        it("saveRole - invalid name", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)
            const roleInvalid = ethers.utils.formatBytes32String("12232323&****")
            await expect(authorizationControl.saveRole(roleInvalid, otherAccount.address)).to.be.revertedWithCustomError(authorizationControl,
                'InvalidName');
        });
    });

    describe("saveRoleGroup", function () {

        it("saveRoleGroup", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)

            const deleteRole = ethers.utils.formatBytes32String("delete_role")
            const groupADM = ethers.utils.formatBytes32String("adm_group")

            await authorizationControl.saveRoleGroup(groupADM, deleteRole, otherAccount.address);
            await authorizationControl.saveRoleGroup(groupADM, deleteRole, owner.address);


            await expect(authorizationControl.saveRoleGroup(groupADM, deleteRole, otherAccount.address)).to.be.revertedWithCustomError(authorizationControl,
                'ROLES_AddressAlreadyHasRoleGroup');


            const users1 = await authorizationControl.getUsersByRoleGroup(groupADM, deleteRole)
            //console.log(users1)
            await authorizationControl.removeRoleGroup(groupADM, deleteRole, otherAccount.address)
            const users2 = await authorizationControl.getUsersByRoleGroup(groupADM, deleteRole)
            //console.log(users2)

            const addRolex = ethers.utils.formatBytes32String("123333")
            await expect(authorizationControl.saveRoleGroup(groupADM, addRolex, otherAccount.address)).to.be.revertedWithCustomError(authorizationControl,
                'InvalidName');

        });

    });

    describe("removeRole", function () {

        it("removeRole", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)
            const roleAdd = ethers.utils.formatBytes32String("add_role")
            await authorizationControl.saveRole(roleAdd, otherAccount.address);
            await authorizationControl.saveRole(roleAdd, owner.address);

            await authorizationControl.removeRole(roleAdd, owner.address)
            await expect(authorizationControl.removeRole(roleAdd, owner.address)).to.be.revertedWithCustomError(authorizationControl,
                'ROLES_AddressDoesNotHaveRole');
        });
    });




    describe("removeRoleGroup", function () {

        it("removeRoleGroup", async function () {

            const { animalManager, pessoasManager, authorizationControl, owner, otherAccount } = await loadFixture(deployContract)
            const roleAdd = ethers.utils.formatBytes32String("add_role")
            const groupADM = ethers.utils.formatBytes32String("adm_group")
            await authorizationControl.saveRoleGroup(groupADM, roleAdd, otherAccount.address)
            await authorizationControl.saveRoleGroup(groupADM, roleAdd, owner.address)
            await authorizationControl.removeRoleGroup(groupADM, roleAdd, owner.address)

            await expect(authorizationControl.removeRoleGroup(groupADM, roleAdd, owner.address)).to.be.revertedWithCustomError(authorizationControl,
                'ROLES_AddressDoesNotHaveRoleGroup');
        });
    });

});
