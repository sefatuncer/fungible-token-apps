// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC1363.sol";
import "@openzeppelin/contracts/interfaces/IERC777.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// // ERC20 token sample for test
// contract SampleToken1363 is ERC20 {
//     constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
//         _mint(msg.sender, 1000000 * 10 ** uint256(decimals()));
//     }
// }

// // ERC777 token sample for test
// contract SampleToken777 is ERC20, IERC777{
//     constructor(string memory _name, string memory _symbol) IERC777(_name, _symbol, new address[](0)) {
//         _mint(msg.sender, 1000000 * 10 ** uint256(decimals()));
//     }
// }

contract TokenSaleWithBondingCurve is Ownable2Step {
    using Math for uint256;

    IERC1363 public token1363; // ERC1363 token contract
    IERC777 public token777;   // ERC777 token contract

    uint256 public slope;         // Linear bonding curve slope
    uint256 public initialPrice;  // Initial token price
    uint256 public tokensSold;    // Total tokens sold

    mapping(address => uint256) public userBalances; // User token balances

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 revenue);

    constructor(
        address _token1363Address,
        address _token777Address,
        uint256 _slope,
        uint256 _initialPrice,
        address initialOwner
    ) Ownable(initialOwner){
        token1363 = IERC1363(_token1363Address);
        token777 = IERC777(_token777Address);
        slope = _slope;
        initialPrice = _initialPrice;
        initialOwner = msg.sender;
    }

    // Fallback function to receive ETH
    receive() external payable {
        // Convert incoming ETH to tokens and assign them to the sender
        uint256 purchasedTokens = calculateTokensFromEther(msg.value);
        userBalances[msg.sender] = userBalances[msg.sender]+purchasedTokens;
        tokensSold = tokensSold + purchasedTokens;

        emit TokensPurchased(msg.sender, purchasedTokens, msg.value);
    }

    function purchaseTokens(uint256 amount) external {
        // Calculate the price based on the bonding curve
        uint256 price = calculatePrice(amount);

        // Ensure the contract has enough tokens to sell
        require(token1363.balanceOf(address(this)) >= price, "Insufficient tokens in reserve");

        // Transfer tokens to the sender
        require(token1363.transfer(msg.sender, price), "Token transfer failed");

        // Update user balance and tokens sold
        userBalances[msg.sender] = userBalances[msg.sender] + amount;
        tokensSold = tokensSold + amount;

        emit TokensPurchased(msg.sender, amount, price);
    }

    function sellTokens(uint256 amount) external {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");

        // Calculate the sell price based on the bonding curve
        uint256 sellPrice = calculatePrice(amount);

        // Ensure the contract has enough ETH to buy back tokens
        require(address(this).balance >= sellPrice, "Insufficient ETH in the contract");

        // Transfer tokens from the sender to the contract
        require(token1363.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Transfer ETH to the sender
        payable(msg.sender).transfer(sellPrice);

        // Update user balance and tokens sold
        userBalances[msg.sender] = userBalances[msg.sender]-amount;
        tokensSold = tokensSold-amount;

        emit TokensSold(msg.sender, amount, sellPrice);
    }

    function calculatePrice(uint256 tokensToBuy) internal view returns (uint256) {
        return initialPrice+slope*tokensToBuy;
    }

    function calculateTokensFromEther(uint256 etherAmount) internal view returns (uint256) {
        // Calculate the number of tokens that can be purchased with the given amount of ETH
        // return etherAmount.tryMul(1e18)/(initialPrice.tryAdd(slope.tryMul(tokensSold)));
        return etherAmount*(1e18)/(initialPrice+(slope*tokensSold));
    }

    // Withdraw ETH from the contract (only owner)
    function withdrawEther(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner()).transfer(amount);
    }
}
