// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
// Use Ownable2Step instead of Ownable for mistyped address and zero address.

contract UntrustedEscrow is Ownable2Step {
    struct Escrow {
        address buyer;
        address seller;
        uint256 releaseTime;
        uint256 amount;
        bool isActive; // for reentrancy
    }

    IERC20 public token; // Any ERC20 token
    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCount;

    event EscrowCreated(uint256 indexed escrowId, address indexed buyer, address indexed seller, uint256 amount);
    event Withdrawal(uint256 indexed escrowId, address indexed seller, uint256 amount);

    constructor(address _token,address initialOwner) Ownable(initialOwner) {
        token = IERC20(_token);
        initialOwner = msg.sender;
    }

    function createEscrow(address _seller, uint256 _releaseTime, uint256 _amount) external {
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        require(_amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        escrows[escrowCount] = Escrow({
            buyer: msg.sender,
            seller: _seller,
            releaseTime: _releaseTime,
            amount: _amount,
            isActive: true
        });

        emit EscrowCreated(escrowCount, msg.sender, _seller, _amount);
        escrowCount++;
    }

    function withdraw(uint256 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId]; // escrowId is any certain value of escrowCount
        require(escrow.isActive, "Escrow is not active");
        require(msg.sender == escrow.seller, "Only the seller can withdraw funds");
        require(block.timestamp >= escrow.releaseTime + 3 days, "Funds cannot be withdrawn before the release time");

        uint256 balance = token.balanceOf(address(this));
        require(balance >= escrow.amount, "Insufficient balance in the contract");

        escrow.isActive = false;
        require(token.transfer(msg.sender, escrow.amount), "Token transfer failed");

        emit Withdrawal(_escrowId, msg.sender, escrow.amount);
    }

    // In case of disputes, the owner can intervene to refund the funds to the buyer.
    function refundToBuyer(uint256 _escrowId) external onlyOwner {
        Escrow storage escrow = escrows[_escrowId];
        require(escrow.isActive, "Escrow is not active");
        require(block.timestamp >= escrow.releaseTime, "Funds cannot be refunded before the release time");

        uint256 balance = token.balanceOf(address(this));
        require(balance >= escrow.amount, "Insufficient balance in the contract");

        escrow.isActive = false;
        require(token.transfer(escrow.buyer, escrow.amount), "Token transfer failed");

        emit Withdrawal(_escrowId, escrow.buyer, escrow.amount);
    }
}