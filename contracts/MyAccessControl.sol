// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "./AccessControl.sol";
import "hardhat/console.sol";

contract MyAccessControl is AccessControl {
    bytes32 constant ADD_ROLE = "add_role";

    bytes32 constant UPDATE_ROLE = "update_role";

    bytes32 constant DELETE_ROLE = "delete_role";

    error AddRoleError();

    constructor(
        address addrAuthorizationControl
    ) AccessControl(addrAuthorizationControl) {}


/*
    function addRoles(address addrRole) external {
        //authorizationControl.saveRole( ADD_ROLE, addrRole);


        
        (bool successAdd,  bytes memory dataAdd ) = address(authorizationControl).delegatecall(abi.encodeWithSignature("saveRole(bytes32,address)", ADD_ROLE, addrRole));
        (bool successUp,   bytes memory dataUp  ) = address(authorizationControl).delegatecall(abi.encodeWithSignature("saveRole(bytes32,address)", UPDATE_ROLE, addrRole));
        (bool successDel,  bytes memory dataDel ) =  address(authorizationControl).delegatecall(abi.encodeWithSignature("saveRole(bytes32,address)", DELETE_ROLE, addrRole));


        console.log(successAdd);
        

        if ( !(successAdd && successUp   && successDel ) ){
                revert AddRoleError();
        }
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) public pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }  */
}
