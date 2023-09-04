// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "../lib/forge-std/lib/ds-test/src/test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PowerfulAdminToken} from "../src/PowerfulAdminToken.sol";

contract PowerfulAdminTokenTest is DSTest {
    PowerfulAdminToken public token;
    address public admin;
    address public user;

    function setUp() public {
        admin = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // The contract itself is the admin for testing purposes
        user = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8); // Replace the user address with a valid address
        token = new PowerfulAdminToken("MyToken", "MTK", 1000);
        token.changeAdmin(admin);
    }

    function testBanAndUnban() public {
        // Make sure the user is not banned initially.
        assertTrue(!token.bannedAdresses(user), "User is not banned initially");

        // Ban the user.
        token.banAddress(user);
        // Verify that the user is banned.
        assertTrue(token.bannedAdresses(user), "User should be banned");

        // Unban the user.
        token.unBannedAddress(user); 
        // Verify that the user is no longer banned.
        assertTrue(!token.bannedAdresses(user), "User should be unbanned");
    }

    function testTransfer() public {
        // Check initial balances.
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** uint256(token.decimals()), "Incorrect initial balance for contract");
        assertEq(token.balanceOf(user), 0, "Incorrect initial balance for user");

        // Admin attempts to transfer tokens to the user.
        uint256 transferAmount = 100 * 10 ** uint256(token.decimals());
        bool transferSuccess = token.transfer(user, transferAmount);
        // The transfer should succeed.
        assertTrue(transferSuccess, "Transfer should succeed");

        // Check balances (Transfer should be from admin to user).
        assertEq(token.balanceOf(address(this)), 900 * 10 ** uint256(token.decimals()), "Incorrect balance for contract after transfer");
        assertEq(token.balanceOf(user), transferAmount, "Incorrect balance for user after transfer");

        // Test transfer to banned addresses.
        token.banAddress(user); // Ban the user.
        transferSuccess = token.transfer(address(this), transferAmount);
        // The transfer should fail because it's to a banned address.
        assertTrue(!transferSuccess, "Transfer to banned address should fail");
    }
}

