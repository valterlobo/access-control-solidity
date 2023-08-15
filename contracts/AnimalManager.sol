// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "./AccessControlRoleGroup.sol";
import "./security/AccessControlProxy.sol";

contract AnimalManager is AccessControlRoleGroup, AccessControlProxy{
    struct Animal {
        string name;
        string tipo;
        uint8 idade;
        uint id;
        address owner;
    }

    uint count;

    mapping(uint => Animal) private animais;

    constructor(address addrAcessControl) AccessControlProxy(addrAcessControl){
        count = 0;
    }

    function addAnimal(
        string memory pName,
        string memory pTipo,
        uint8 pIdade
    ) public onlyRole(AccessControlRoleGroup.ADD_ROLE) {
        count += 1;
        animais[count] = Animal(pName, pTipo, pIdade, count, msg.sender);
    }

    function deleteAnimal(
        uint id
    )
        public
        onlyRoleGroup(
            AccessControlRoleGroup.ADM_GROUP,
            AccessControlRoleGroup.DELETE_ROLE
        )
    {
        delete animais[id];
    }

    function readAnimal(uint id) public view returns (Animal memory) {
        return animais[id];
    }
}
