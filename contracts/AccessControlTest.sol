// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "./MyAccessControl.sol";

contract AccessControlTest is MyAccessControl {
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
        string memory _name,
        uint8 _idade
    ) public onlyRole(MyAccessControl.ADD_ROLE) {
        count += 1;
        Pessoa memory pessoa = Pessoa(_name, _idade, count, msg.sender);
        pessoas[count] = pessoa;
        emit PessoaAdicionada(count, _name);
    }

    // Funções Getters & Setter para nome
    function readPessoa(uint _id) public view returns (Pessoa memory) {
        return pessoas[_id];
    }

    function updateName(
        uint _id,
        string memory _name
    ) public onlyRole(MyAccessControl.UPDATE_ROLE) {
        pessoas[_id].name = _name;
    }

    function updateIdade(
        uint _id,
        uint8 _idade
    ) public onlyRole(MyAccessControl.UPDATE_ROLE) {
        pessoas[_id].idade = _idade;
    }

    function deletePessoa(
        uint _id
    ) public onlyRole(MyAccessControl.DELETE_ROLE) {
        delete pessoas[_id];
    }
}
