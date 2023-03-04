// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IAuthorizationControl.sol";
import "./Owned.sol";

import "hardhat/console.sol";

contract AuthorizationControl is ERC165, IAuthorizationControl, Owned {
    // =========  EVENTS ========= //

    event RoleGranted(bytes32 indexed role_, address indexed addr_);
    event RoleRevoked(bytes32 indexed role_, address indexed addr_);

    // =========  ERRORS ========= //

    error ROLES_InvalidRole(bytes32 role_);
    error ROLES_RequireRole(bytes32 role_);
    error ROLES_AddressAlreadyHasRole(address addr_, bytes32 role_);
    error ROLES_AddressDoesNotHaveRole(address addr_, bytes32 role_);
    error ROLES_RoleDoesNotExist(bytes32 role_);

    // =========  STATE ========= //

    /// @notice Mapping for if an address has a policy-defined role.
    mapping(address => mapping(bytes32 => bool)) public hasRole;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) Owned(_owner) {
        console.log("constructor", _owner);
    }

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    /// @notice Function to grant policy-defined roles to some address. Can only be called by admin.
    function saveRole(bytes32 role_, address addr_) public onlyOwner {
        console.log(msg.sender);

        if (hasRole[addr_][role_])
            revert ROLES_AddressAlreadyHasRole(addr_, role_);

        ensureValidRole(role_);

        // Grant role to the address
        hasRole[addr_][role_] = true;

        emit RoleGranted(role_, addr_);
    }

    /// @notice "Modifier" to restrict policy function access to certain addresses with a role.
    function removeRole(bytes32 role_, address addr_) external onlyOwner {
        if (!hasRole[addr_][role_])
            revert ROLES_AddressDoesNotHaveRole(addr_, role_);

        hasRole[addr_][role_] = false;

        emit RoleRevoked(role_, addr_);
    }

    //============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    //============================================================================================//

    /// @notice "Modifier" to restrict policy function access to certain addresses with a role.
    function requireRole(bytes32 role_, address caller_) external view {
        if (!hasRole[caller_][role_]) revert ROLES_RequireRole(role_);
    }

    /// @notice Function that checks if role is valid (all lower case)
    function ensureValidRole(bytes32 role_) public pure {
        for (uint256 i = 0; i < 32; ) {
            bytes1 char = role_[i];
            if ((char < 0x61 || char > 0x7A) && char != 0x5f && char != 0x00) {
                revert ROLES_InvalidRole(role_); // a-z only
            }
            unchecked {
                i++;
            }
        }
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    //============================================================================================//
    //                                 EXTENDING FUNCTIONS                                       //
    //============================================================================================//

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IAuthorizationControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
