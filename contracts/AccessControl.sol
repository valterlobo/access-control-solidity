// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "./AuthorizationControl.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract AccessControl {
    using Address for address;

    IAuthorizationControl public authorizationControl;

    constructor(address addrAuthorizationControl) {
        require(
            addrAuthorizationControl.isContract(),
            "IAuthorizationControl address must be a contract"
        );

        bool checkIsCourseClassCertificateType = ERC165Checker
            .supportsInterface(
                addrAuthorizationControl,
                type(IAuthorizationControl).interfaceId
            );
        require(
            checkIsCourseClassCertificateType,
            "AuthorizationControl address must be the same type IAuthorizationControl"
        );

        authorizationControl = AuthorizationControl(addrAuthorizationControl);
    }

    modifier onlyRole(bytes32 role_) {
        authorizationControl.requireRole(role_, msg.sender);
        _;
    }

    modifier onlyMaster() virtual {
        require(msg.sender == authorizationControl.getOwner(), "UNAUTHORIZED");

        _;
    }

    function setAuthorizationControl(
        AuthorizationControl authorizationControl_
    ) external onlyMaster {
        authorizationControl = authorizationControl_;
    }
}
