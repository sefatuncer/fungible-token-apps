# fungible-token-apps

# Solidity Contracts Overview

## Contract 1: Token with Sanctions (PowerfulAdminToken)
This contract represents a fungible token that includes a mechanism for an admin to ban specific addresses from sending and receiving tokens. The primary goal of this contract is to control token transfers by allowing the admin to enforce sanctions on specific users, providing additional security and governance capabilities.

## Contract 2: Token with God Mode (GodeModeToken)
In this contract, a special address is granted "god mode" privileges, allowing it to transfer tokens between different addresses without restrictions. The purpose of this contract is to demonstrate how certain addresses can have enhanced control over token transfers, often used in testing or emergency situations.

## Contract 3: Token Sale and Buyback with Bonding Curve (TokenSaleWithBondingCurve)
This contract implements a token sale and buyback mechanism with a linear bonding curve. The bonding curve makes tokens more expensive as more tokens are purchased, simulating a supply and demand relationship. It is designed to illustrate the concept of bonding curves and their usage in token ecosystems. The contract supports sending tokens using ERC1363 or ERC777 standards and handles fractions of tokens.

## Contract 4: Untrusted Escrow (UntrustedEscrow)
The Untrusted Escrow contract allows a buyer to deposit an arbitrary ERC20 token into the contract, and a seller can withdraw it after a specified waiting period (3 days in this case). This contract addresses the need for secure and trustless escrow services in various decentralized applications. It aims to guard against issues such as reentrancy attacks, insufficient balance, and unauthorized withdrawals.

Each of these contracts serves a unique purpose and highlights different aspects of smart contract development and token management. They can be valuable building blocks for various decentralized applications and can be customized further to meet specific project requirements.
