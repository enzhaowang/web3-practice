// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Bank {
    address public immutable owner;
    mapping (address => uint) public balances;
    address[3] topDepositors;
    uint8 private constant TOP_COUNT = 3; 

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { 
        _handleDeposit();
    }

    fallback() external payable { 
        
    }

    function deposit() external payable {
        _handleDeposit();
    }

    function _handleDeposit() internal {
        balances[msg.sender] += msg.value;
        _updateTopDepositors(msg.sender);
    }

    function _updateTopDepositors(address depositor) internal {
        //if depositor already in top3
        for(uint8 i = 0; i < TOP_COUNT; i++) {
            if(topDepositors[i] == depositor) {
                _updateRanking();
                return;
            }
        }

        for(uint8 i = 0; i < TOP_COUNT -1 ; i++) {

            address currentAdd = topDepositors[i];
            if(currentAdd == address(0) || balances[depositor] > balances[currentAdd]) {
                //insert depostor to current address
                for(uint8 j = 2; j > i ; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = depositor;
                break;
            }
        }
    }


    function _updateRanking() internal{

        for(uint8 i = 0; i < TOP_COUNT - 1; i++) {
            for(uint8 j = i + 1; j < TOP_COUNT; j++) {
                if(topDepositors[i] == address(0) || balances[topDepositors[j]] > balances[topDepositors[i]]) {
                    (topDepositors[i], topDepositors[j]) = (topDepositors[j], topDepositors[i]);
                }
            }
        }
    }

    function getTopDepositors() external view returns (address[3] memory , uint[3] memory) {
        uint[3] memory topAmounts;
        for(uint8 i = 0; i < TOP_COUNT; i++) {
            topAmounts[i] = balances[topDepositors[i]];
        }
        return (topDepositors, topAmounts);
    }




    function withdraw() external {

        require(msg.sender == owner, "Only owner can call this function");

        uint balance = address(this).balance;

        require(balance > 0, "Balance should more than 0");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "withdraw failed");

    }









}