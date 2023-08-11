// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "./AuthorizationControl.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract AccessControl {
    using Address for address;

    // =========  ERRORS ========= //
    error ROLES_RequireRole(bytes32 role);
    error ROLES_RequireRoleGroup(bytes32 group, bytes32 role);

    IAuthorizationControl public authorizationControl;

    constructor(address addrAuthorizationControl) {
        require(
            addrAuthorizationControl.isContract(),
            "IAuthorizationControl address must be a contract"
        );

        bool checkIsAuthorizationControl = ERC165Checker.supportsInterface(
            addrAuthorizationControl,
            type(IAuthorizationControl).interfaceId
        );
        require(
            checkIsAuthorizationControl,
            "AuthorizationControl address must be the same type IAuthorizationControl"
        );

        authorizationControl = IAuthorizationControl(addrAuthorizationControl);
    }

    //======MODIFIER ==========//
    modifier onlyRole(bytes32 role) {
        if (!authorizationControl.requireRole(role, msg.sender))
            revert ROLES_RequireRole(role);
        _;
    }

    modifier onlyRoleGroup(bytes32 group, bytes32 role) {
        if (!authorizationControl.requireRoleGroup(group, role, msg.sender))
            revert ROLES_RequireRoleGroup(group, role);
        _;
    }

    modifier onlyMaster() virtual {
        require(msg.sender == authorizationControl.getMaster(), "UNAUTHORIZED");

        _;
    }

    function setAuthorizationControl(
        AuthorizationControl authorizationControl_
    ) external onlyMaster {
        authorizationControl = authorizationControl_;
    }

    function getAuthorizationControl()
        external
        view
        onlyMaster
        returns (address)
    {
        return address(authorizationControl);
    }
}
