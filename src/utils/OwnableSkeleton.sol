// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOwnable} from "../interfaces/IOwnable.sol";

contract OwnableSkeleton is IOwnable {
    address private _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _setOwner(address newAddress) internal {
        emit OwnershipTransferred(_owner, newAddress);
        _owner = newAddress;
    }
}
