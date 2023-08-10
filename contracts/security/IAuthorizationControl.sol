// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

interface IAuthorizationControl {
    function ensureValidName(bytes32 role) external;

    function requireRole(bytes32 role, address caller) external;

    function requireRoleGroup(
        bytes32 group,
        bytes32 role,
        address caller
    ) external;

    function removeRole(bytes32 role, address addr) external;

    function saveRole(bytes32 role, address addr) external;

    function getOwner() external view returns (address);
}
