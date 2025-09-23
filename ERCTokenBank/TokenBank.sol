// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";

interface ItokenReceiver{
    function tokenReceived(address from, uint256 amount) external returns (bool);

}
contract TokenBank is Ownable, ReentrancyGuard, ItokenReceiver{

    using SafeERC20 for IERC20;

    /*
       Errors
    */
    error ZeroAmount();
    error InsufficientBalance();

    /*
      States
    */
    IERC20 public immutable token;
    mapping(address => uint256) private balances;
    uint256 public totalBalance;

    /**
     Events
    */
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);


    /**
     Constructor
    */
    constructor(address token_) Ownable(msg.sender) {
        require(token_ != address(0), "Token address can not be zero");
        token = IERC20(token_);
    }


    /**
        user actions
    **/

    function deposit(uint256 amount) external  nonReentrant {
        if(amount == 0) {
            revert ZeroAmount();
        }

        //transfer, need to approve first
        token.safeTransferFrom(msg.sender, address(this), amount);

        totalBalance += amount;
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);

    }


    function withdraw(uint256 amount) external nonReentrant {
        if(amount == 0) revert ZeroAmount();
        if(amount < balances[msg.sender]) revert InsufficientBalance();

        balances[msg.sender] -= amount;
        totalBalance -= amount;
        
        token.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function tokenReceived(address from, uint256 amount) external returns (bool) {
        require(msg.sender == address(token), "caller is not the token contract");

        balances[from] += amount;
        totalBalance += amount;

        emit Deposit(from, amount);
        return true;
    }


    /*
    ########## views
    */

    function balanceOf(address user) external view returns(uint256 balance) {
        require(user != address(0), "address can not be 0");
        balance = balances[user];
    } 
}