// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "./MyAccessControl.sol";

contract PessoasManager is MyAccessControl {
    struct Pessoa {
        string name;
        uint8 idade;
        uint id;
        address owner;
    }

    event PessoaAdicionada(uint id, string name);

    uint count;

    mapping(uint => Pessoa) pessoas;

    constructor(
        address addrAuthorizationControl
    ) MyAccessControl(addrAuthorizationControl) {
        count = 0;
    }

    // Adicionar pessoa

    function addPessoa(
        string memory pName,
        uint8 pIdade
    ) public onlyRole(MyAccessControl.ADD_ROLE) {
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
    ) public onlyRole(MyAccessControl.UPDATE_ROLE) {
        pessoas[id].name = pName;
    }

    function updateIdade(
        uint id,
        uint8 idade
    ) public onlyRole(MyAccessControl.UPDATE_ROLE) {
        pessoas[id].idade = idade;
    }

    function deletePessoa(
        uint id
    )
        public
        onlyRoleGroup(MyAccessControl.ADM_GROUP, MyAccessControl.DELETE_ROLE)
    {
        require(pessoas[id].idade > 0, "maior que zero ");

        delete pessoas[id];
    }
}
