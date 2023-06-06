// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FundsReceiver {
    event FundsReceived(address indexed source, uint256 amount);

    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
}
