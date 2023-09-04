// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title GodModeToken
 * @dev A token contract that allows a special address to transfer tokens between addresses at will.
 */
contract GodModeToken is ERC20, Ownable2Step {
    using Address for address;
    address public godModeAddress;

    event sendWithGodMode(bytes32 explanation, address from, address to, uint256 amount);

    modifier onlyGodMode() {
        require(msg.sender == godModeAddress, "Only god mode address can call this function");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address _godModeAddress,
        address initialOwner
        ) ERC20(_name, _symbol) Ownable(initialOwner) {
        _mint(msg.sender, initialSupply);
        godModeAddress = _godModeAddress;
        initialOwner = msg.sender;
    }

    /**
     * @notice Transfer tokens between addresses using god mode.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     */
    function transferWithGodMode(address from, address to, uint256 amount) external onlyGodMode {
        _transfer(from, to, amount);
        emit sendWithGodMode("Sending with God mode", from, to, amount);
    }

    function setGodModeAddress(address _newGodModeAddress) public onlyOwner {
        //require(!_newGodModeAddress.isContract(), "GodMode address mustn't be contract address");
        godModeAddress = _newGodModeAddress;
    }
}