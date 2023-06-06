// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IOwnable {
    error ONLY_OWNER();
    error ONLY_PENDING_OWNER();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event OwnerPending(address indexed previousOwner, address indexed potentialNewOwner);

    event OwnerCanceled(address indexed previousOwner, address indexed potentialNewOwner);

    function owner() external view returns (address);
}
