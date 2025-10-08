// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


interface IBank {
    function deposit() external ;

    function getTopDepositors() external view returns (address[3] memory, uint[3] memory);

    function withdraw() external;
}



contract Bank {
    address public owner;
    mapping (address => uint) public balances;
    address[3] topDepositors;
    uint8 private constant TOP_COUNT = 3;


    receive() external payable virtual  { 
        _handleDeposit();
    }

    fallback() external payable { 
        
    }

    function deposit() external payable virtual  {
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

contract BigBank is Bank {
    address bigBankOwner;

    constructor() {
        bigBankOwner = msg.sender;
    }


    modifier depositMinValue() {
        require(msg.value > 0.001 ether, "the min value required to be larger than 0.001 ether");
        _;
    }

    function deposit() external payable override depositMinValue   {
        _handleDeposit();
    }

    receive() external payable override depositMinValue {
        _handleDeposit();
     }

    function transferAdministration(address newOwner) external {
        require(msg.sender == bigBankOwner, "only owner can transfer owner");
        require(newOwner != address(0), "new Owner can not be zero address");
        owner = newOwner;
    }

    
}


contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner call this function");
        _;
    }


    function adminWithdraw(IBank bank) external onlyOwner {
        bank.withdraw();
    }

    function withdrawAdmin() external  onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "Balance must larger than 0");
        (bool success, ) = owner.call{value:balance}("");
        require(success, "withdraw failed"); 
    }



}