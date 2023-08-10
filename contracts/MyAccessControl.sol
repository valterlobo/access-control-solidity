// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "./security/AccessControl.sol";

contract MyAccessControl is AccessControl {

    
    bytes32 constant ADM_GROUP = "adm_group";

    bytes32 constant USER_GROUP = "user_group";

    bytes32 constant ADD_ROLE = "add_role";

    bytes32 constant UPDATE_ROLE = "update_role";

    bytes32 constant DELETE_ROLE = "delete_role";

    bytes32 constant AUDIT_ROLE = "audit_role";


    constructor(address authControl) AccessControl(authControl) {}


}
