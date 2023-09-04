// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "../lib/forge-std/lib/ds-test/src/test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {GodModeToken} from "../src/GodModeToken.sol";

contract GodModeTokenTest is DSTest {
    GodModeToken public token;
    address public owner;
    address public godModeAddress;
    address public user1;

    function setUp() public {
        owner = address(this); // Set the contract owner as the address of the test contract
        godModeAddress = address(0x123); // Replace the godModeAddress with an appropriate address
        user1 = address(0x456); // Replace the user address with an appropriate address

        token = new GodModeToken("MyToken", "MTK", 1000, godModeAddress, owner);
    }

    function testTransferWithGodMode() public {
        // Check initial balances
        assertEq(token.balanceOf(owner), 1000, "Incorrect initial balance for owner");
        assertEq(token.balanceOf(godModeAddress), 0, "Incorrect initial balance for godModeAddress");
        assertEq(token.balanceOf(user1), 0, "Incorrect initial balance for user1");

        // Perform a transfer with God Mode
        uint256 transferAmount = 100;
        token.transferWithGodMode(owner, user1, transferAmount);

        // Check balances (Transfer should be from owner to user1)
        assertEq(token.balanceOf(owner), 900, "Incorrect balance for owner after transfer");
        assertEq(token.balanceOf(user1), transferAmount, "Incorrect balance for user1 after transfer");
    }

    function testSetGodModeAddress() public {
        // Only the owner can change the God Mode address
        address newGodModeAddress = address(0x789);
        token.setGodModeAddress(newGodModeAddress);
        assertEq(token.godModeAddress(), newGodModeAddress, "God Mode address should be updated");
    }
}
