// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

abstract contract Master {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event MasterTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyMaster() virtual {
        //console.log("onlyOwner", owner);
        //console.log("(msg.sender ", msg.sender);
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit MasterTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferMaster(address newOwner) public virtual onlyMaster {
        require(newOwner != address(0), "Invalid address(0)");
        owner = newOwner;
        emit MasterTransferred(msg.sender, newOwner);
    }
}
