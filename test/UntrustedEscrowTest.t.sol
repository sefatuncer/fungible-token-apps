// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "../lib/forge-std/lib/ds-test/src/test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/UntrustedEscrow.sol";

contract UntrustedEscrowTest is DSTest {
    UntrustedEscrow public escrow;
    IERC20 public token;
    address public seller;
    address public buyer;
    address public owner;

    uint256 public initialBalance = 1000 ether;

    function setUp() public {
        token = IERC20(address(this)); // Use the test contract as the ERC20 token
        escrow = new UntrustedEscrow(address(token), address(this));
        seller = address(0x123); // Replace with the appropriate seller address
        buyer = address(0x456); // Replace with the appropriate buyer address
        owner = msg.sender;
        token.transfer(seller, initialBalance);
    }

    function testCreateEscrow() public {
        uint256 escrowId = escrow.escrowCount();
        uint256 amount = 100 ether;
        uint256 releaseTime = block.timestamp + 1 days;

        escrow.createEscrow{value: amount}(seller, releaseTime, amount);

        assertEq(escrow.escrowCount(), escrowId + 1, "Escrow count should increase");
        assertEq(escrow[escrowCount()].buyer, msg.sender, "Buyer should be the sender");
        assertEq(escrow(escrowId).seller, seller, "Seller should match");
        assertEq(escrow(escrowId).releaseTime, releaseTime, "Release time should match");
        assertEq(escrow(escrowId).amount, amount, "Escrow amount should match");
        assertTrue(escrow(escrowId).isActive, "Escrow should be active");
    }

    function testWithdraw() public {
        uint256 escrowId = escrow.escrowCount();
        uint256 amount = 100 ether;
        uint256 releaseTime = block.timestamp - 1 days;

        escrow.createEscrow{value: amount}(seller, releaseTime, amount);

        assertEq(token.balanceOf(seller), initialBalance, "Seller balance should not change before withdrawal");
        assertEq(token.balanceOf(address(escrow)), amount, "Escrow contract should hold the amount");

        escrow.withdraw(escrowId);

        assertEq(token.balanceOf(seller), initialBalance + amount, "Seller should receive funds after withdrawal");
        assertEq(token.balanceOf(address(escrow)), 0, "Escrow contract should not hold any funds after withdrawal");
        assertFalse(escrow.escrows(escrowId).isActive, "Escrow should be inactive after withdrawal");
    }

    function testRefundToBuyer() public {
        uint256 escrowId = escrow.escrowCount();
        uint256 amount = 100 ether;
        uint256 releaseTime = block.timestamp - 1 days;

        escrow.createEscrow{value: amount}(seller, releaseTime, amount);

        assertEq(token.balanceOf(buyer), 0, "Buyer balance should be zero before refund");

        escrow.refundToBuyer(escrowId);

        assertEq(token.balanceOf(buyer), amount, "Buyer should receive refund");
        assertFalse(escrow.escrows(escrowId).isActive, "Escrow should be inactive after refund");
    }
}
