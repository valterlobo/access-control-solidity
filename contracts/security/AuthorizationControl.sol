// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IAuthorizationControl.sol";
import "./Owned.sol";

contract AuthorizationControl is ERC165, IAuthorizationControl, Owned {
    // =========  EVENTS ========= //

    event RoleGranted(bytes32 indexed role, address indexed addr);
    event RoleRevoked(bytes32 indexed role, address indexed addr);

    event RoleGroupGranted(
        bytes32 indexed group,
        bytes32 indexed role,
        address indexed addr
    );
    event RoleGroupRevoked(
        bytes32 indexed group,
        bytes32 indexed role,
        address indexed addr
    );

    // =========  ERRORS ========= //

    error ROLES_InvalidRole(bytes32 role_);
    error ROLES_RequireRole(bytes32 role_);
    error ROLES_AddressAlreadyHasRole(address addr_, bytes32 role_);
    error ROLES_AddressDoesNotHaveRole(address addr_, bytes32 role_);
    error ROLES_RoleDoesNotExist(bytes32 role_);

    error ROLES_AddressAlreadyHasRoleGroup(
        address addr,
        bytes32 group,
        bytes32 role
    );

    error ROLES_RequireRoleGroup(bytes32 group, bytes32 role);

    error ROLES_AddressDoesNotHaveRoleGroup(
        address addr,
        bytes32 group,
        bytes32 role
    );

    error InvalidName(bytes32 nm);

    //======MODIFIER ==========//
    modifier onlyRole(bytes32 role_) {
        requireRole(role_, msg.sender);
        _;
    }

    modifier onlyRoleGroup(bytes32 group, bytes32 role) {
        requireRoleGroup(group, role, msg.sender);
        _;
    }

    modifier onlyMaster() virtual {
        require(msg.sender == getOwner(), "UNAUTHORIZED");

        _;
    }

    // =========  STATE ========= //

    /// @notice Mapping for if an address has a policy-defined role.
    mapping(address => mapping(bytes32 => bool)) public hasRole;
    mapping(address => mapping(bytes32 => mapping(bytes32 => bool)))
        public hasRoleGroup;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) Owned(_owner) {}

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    /// @notice Function to grant policy-defined roles to some address. Can only be called by admin.
    function saveRole(bytes32 role, address addr) public onlyOwner {
        if (hasRole[addr][role]) revert ROLES_AddressAlreadyHasRole(addr, role);

        ensureValidName(role);

        // Grant role to the address
        hasRole[addr][role] = true;

        emit RoleGranted(role, addr);
    }

    function saveRoleGroup(
        bytes32 group,
        bytes32 role,
        address addr
    ) public onlyOwner {
        if (hasRoleGroup[addr][group][role])
            revert ROLES_AddressAlreadyHasRoleGroup(addr, group, role);

        ensureValidName(role);
        ensureValidName(group);

        // Grant role to the address
        hasRoleGroup[addr][group][role] = true;

        emit RoleGroupGranted(group, role, addr);
    }

    /// @notice "Modifier" to restrict policy function access to certain addresses with a role.
    function removeRole(bytes32 role_, address addr_) external onlyOwner {
        if (!hasRole[addr_][role_])
            revert ROLES_AddressDoesNotHaveRole(addr_, role_);

        hasRole[addr_][role_] = false;

        emit RoleRevoked(role_, addr_);
    }

    function removeRoleGroup(
        bytes32 group,
        bytes32 role,
        address addr
    ) external onlyOwner {
        if (!hasRoleGroup[addr][group][role])
            revert ROLES_AddressDoesNotHaveRoleGroup(addr, group, role);

        hasRoleGroup[addr][group][role] = false;

        emit RoleGroupRevoked(group, role, addr);
    }

    //============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    //============================================================================================//

    /// @notice "Modifier" to restrict policy function access to certain addresses with a role.
    function requireRole(bytes32 role, address caller) public view {
        if (!hasRole[caller][role]) revert ROLES_RequireRole(role);
    }

    function requireRoleGroup(
        bytes32 group,
        bytes32 role,
        address caller
    ) public view {
        if (!hasRoleGroup[caller][group][role])
            revert ROLES_RequireRoleGroup(group, role);
    }

    function ensureValidName(bytes32 nm) public pure {
        for (uint256 i = 0; i < 32; ) {
            bytes1 char = nm[i];
            if ((char < 0x61 || char > 0x7A) && char != 0x5f && char != 0x00) {
                revert InvalidName(nm); // a-z only
            }
            unchecked {
                i++;
            }
        }
    }

    function getOwner() public view returns (address) {
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
