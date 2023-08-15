// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IAuthorizationControl.sol";
import "./Master.sol";

contract AuthorizationControl is ERC165, IAuthorizationControl, Master {
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
    error ROLES_InvalidRole(bytes32 role);
    error ROLES_AddressAlreadyHasRole(address addr, bytes32 role);
    error ROLES_AddressDoesNotHaveRole(address addr, bytes32 role);
    error ROLES_RoleDoesNotExist(bytes32 role);

    error ROLES_AddressAlreadyHasRoleGroup(
        address addr,
        bytes32 group,
        bytes32 role
    );

    error ROLES_AddressDoesNotHaveRoleGroup(
        address addr,
        bytes32 group,
        bytes32 role
    );

    error InvalidName(bytes32 nm);

    // =========  STATE ========= //
    //Roles
    mapping(address => mapping(bytes32 => bool)) private hasRole;
    mapping(bytes32 => address[]) private usersRole;
    bytes32[] public roles;

    //Role Group
    mapping(address => mapping(bytes32 => mapping(bytes32 => bool)))
        public hasRoleGroup;
    mapping(bytes32 => mapping(bytes32 => address[])) public usersRoleGroup;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) Master(_owner) {}

    //============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    //============================================================================================//

    function saveRole(bytes32 role, address addr) public onlyMaster {
        if (hasRole[addr][role]) revert ROLES_AddressAlreadyHasRole(addr, role);

        ensureValidName(role);

        // Grant role to the address
        hasRole[addr][role] = true;
        usersRole[role].push(addr);
        emit RoleGranted(role, addr);
    }

    function saveRoleGroup(
        bytes32 group,
        bytes32 role,
        address addr
    ) public onlyMaster {
        if (hasRoleGroup[addr][group][role])
            revert ROLES_AddressAlreadyHasRoleGroup(addr, group, role);

        ensureValidName(role);
        ensureValidName(group);

        // Grant role to the address
        hasRoleGroup[addr][group][role] = true;
        usersRoleGroup[group][role].push(addr);
        emit RoleGroupGranted(group, role, addr);
    }

    function removeRole(bytes32 role, address addr) external onlyMaster {
        if (!hasRole[addr][role])
            revert ROLES_AddressDoesNotHaveRole(addr, role);

        hasRole[addr][role] = false;

        address[] memory users = usersRole[role];
        int idx = findIndex(addr, users);
        if (idx >= 0) {
            uint i = uint(idx);
            address[] storage arrUsers = usersRole[role];
            arrUsers[i] = arrUsers[arrUsers.length - 1];
            //delete the last element
            arrUsers.pop();
        }

        emit RoleRevoked(role, addr);
    }

    function removeRoleGroup(
        bytes32 group,
        bytes32 role,
        address addr
    ) external onlyMaster {
        if (!hasRoleGroup[addr][group][role])
            revert ROLES_AddressDoesNotHaveRoleGroup(addr, group, role);

        hasRoleGroup[addr][group][role] = false;

        address[] memory usersGroup = usersRoleGroup[group][role];
        int idx = findIndex(addr, usersGroup);
        if (idx >= 0) {
            uint i = uint(idx);
            address[] storage arrUsers = usersRoleGroup[group][role];
            arrUsers[i] = arrUsers[arrUsers.length - 1];
            //delete the last element
            arrUsers.pop();
        }
        emit RoleGroupRevoked(group, role, addr);
    }

    //============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    //============================================================================================//

    function requireRole(
        bytes32 role,
        address caller
    ) public view returns (bool) {
        return hasRole[caller][role];
    }

    function requireRoleGroup(
        bytes32 group,
        bytes32 role,
        address caller
    ) public view returns (bool) {
        return hasRoleGroup[caller][group][role];
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

    function findIndex(
        address value,
        address[] memory values
    ) public pure returns (int) {
        for (uint i = 0; i < values.length; i++) {
            if (values[i] == value) {
                return int(i);
            }
        }
        return -1;
    }

    function getUsersByRole(
        bytes32 role
    ) public view returns (address[] memory) {
        return usersRole[role];
    }

    function getUsersByRoleGroup(
        bytes32 group,
        bytes32 role
    ) public view returns (address[] memory) {
        return usersRoleGroup[group][role];
    }

    function getMaster() public view returns (address) {
        return master;
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
