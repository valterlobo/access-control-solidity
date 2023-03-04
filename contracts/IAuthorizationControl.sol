// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

interface IAuthorizationControl {
    function ensureValidRole(bytes32 role_) external;

    function requireRole(bytes32 role_, address caller_) external;

    function removeRole(bytes32 role_, address addr_) external;

    function saveRole(bytes32 role_, address addr_) external;

    function getOwner() external view returns (address);
}
