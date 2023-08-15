// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "./AuthorizationControl.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract AccessControl {
    using Address for address;

    error UNAUTHORIZED();

    IAuthorizationControl public authorizationControl;

    constructor(address addrAuthorizationControl) {
        verifyAuthorizationControl(addrAuthorizationControl);
        authorizationControl = IAuthorizationControl(addrAuthorizationControl);
    }

    //======MODIFIER ==========//

    modifier onlyMaster() virtual {
        if (!(msg.sender == authorizationControl.getMaster()))
            revert UNAUTHORIZED();
        _;
    }

    function setAuthorizationControl(
        AuthorizationControl authorizationControl_
    ) external onlyMaster {
        verifyAuthorizationControl(address(authorizationControl_));
        authorizationControl = authorizationControl_;
    }

    function getAuthorizationControl() external view returns (address) {
        return address(authorizationControl);
    }

    function verifyRole(
        bytes32 role,
        address caller
    ) public view returns (bool) {
        return authorizationControl.requireRole(role, caller);
    }

    function verifyRoleGroup(
        bytes32 group,
        bytes32 role,
        address caller
    ) public view returns (bool) {
        return authorizationControl.requireRoleGroup(group, role, caller);
    }

    function verifyAuthorizationControl(address authControl) internal view {
        require(
            authControl.isContract(),
            "IAuthorizationControl address must be a contract"
        );

        bool checkIsAuthorizationControl = ERC165Checker.supportsInterface(
            authControl,
            type(IAuthorizationControl).interfaceId
        );
        require(
            checkIsAuthorizationControl,
            "AuthorizationControl address must be the same type IAuthorizationControl"
        );
    }
}
