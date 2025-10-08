// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

interface ItokenReceiver{
    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bool);

}

contract MyERC20 is ERC20 {

    constructor(uint256 initialSupply) ERC20("MyERC20", "MYERC20") {
        _mint(msg.sender, initialSupply);
    }

    function transferWithCallbackAndData(address _to, uint256 _amount, bytes calldata data) external returns(bool) {
        require(balanceOf(msg.sender) >= _amount, "balance is insufficient");
        require(_to != address(0), "address can not be zero");

        transfer(_to, _amount);


        if(isContract(_to)) {
            try ItokenReceiver(_to).tokenReceived(msg.sender, _amount, data) returns (bool) {

            }catch {

            }
        }

        return true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

} 