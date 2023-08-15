// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./AccessControlRoleGroup.sol";
import "./security/AccessControlProxy.sol";

contract PessoasManager is AccessControlRoleGroup, AccessControlProxy {
    struct Pessoa {
        string name;
        uint8 idade;
        uint id;
        address owner;
    }

    event PessoaAdicionada(uint id, string name);

    uint count;

    mapping(uint => Pessoa) pessoas;

    constructor(address addrAcessControl) AccessControlProxy(addrAcessControl) {
        count = 0;
    }

    // Adicionar pessoa

    function addPessoa(
        string memory pName,
        uint8 pIdade
    ) public onlyRole(AccessControlRoleGroup.ADD_ROLE) {
        count += 1;
        Pessoa memory pessoa = Pessoa(pName, pIdade, count, msg.sender);
        pessoas[count] = pessoa;
        emit PessoaAdicionada(count, pName);
    }

    // Funções Getters & Setter para nome
    function readPessoa(uint id) public view returns (Pessoa memory) {
        return pessoas[id];
    }

    function updateName(
        uint id,
        string memory pName
    ) public onlyRole(AccessControlRoleGroup.UPDATE_ROLE) {
        pessoas[id].name = pName;
    }

    function updateIdade(
        uint id,
        uint8 idade
    ) public onlyRole(AccessControlRoleGroup.UPDATE_ROLE) {
        pessoas[id].idade = idade;
    }

    function deletePessoa(
        uint id
    )
        public
        onlyRoleGroup(
            AccessControlRoleGroup.ADM_GROUP,
            AccessControlRoleGroup.DELETE_ROLE
        )
    {
        require(pessoas[id].idade > 0, "maior que zero ");

        delete pessoas[id];
    }
}
