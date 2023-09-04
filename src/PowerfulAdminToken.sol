// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title PowerfulAdminToken
   @dev A custom ERC20 token contract that allows an admin to ban specified addresses from sending and receiving tokens.
*/

contract PowerfulAdminToken is ERC20 {
    address public admin;
    mapping(address => bool) public bannedAdresses;

    event AddressBanned(address indexed user);
    event AddressUnbanned(address indexed user);

    modifier onlyAdmin(){
        require(_msgSender() == admin, "Only admin can perform this action");
        _;
    }

    /**
     * @dev Constructor to initialize the token with a name, symbol and initialSupply.
     * @param _name The name of token.
     * @param _symbol The symbol of token.
     * @param _initialSupply The initial supply of tokens to mint to the contract deployer.
    */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
        ) ERC20(_name,_symbol) {
        _mint(msg.sender, _initialSupply * 10 ** uint256(decimals()));
        admin = msg.sender;
    }

    function changeAdmin(address _newAdmin) external onlyAdmin{
        admin = _newAdmin;
    }

    function banAddress(address _user) external onlyAdmin {
        require(!bannedAdresses[_user], "Address is already banned");
        bannedAdresses[_user] = true;
        emit AddressBanned(_user);
    }

    function unBannedAddress(address _user) external onlyAdmin {
        require(bannedAdresses[_user], "Address is already banned");
        bannedAdresses[_user] = true;
        emit AddressUnbanned(_user);
    }

    /// @notice Override the transfer function to check for sanctions before allowing a transfer.
    function transfer(address to, uint256 value) public override returns (bool) {
        require(!bannedAdresses[msg.sender], "Sender is banned");
        require(!bannedAdresses[to], "Recipient is banned");
        return super.transfer(to,value);
    }

    /// @notice Override the transferFrom function to check for sanctions before allowing a transfer.
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(!bannedAdresses[from], "Sender is banned");
        require(!bannedAdresses[to], "Recipient is banned");
        return super.transferFrom(from, to , value);
    }
}