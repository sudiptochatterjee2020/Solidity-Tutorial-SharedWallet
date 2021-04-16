//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./Allowance.sol";

contract SharedWallet is Allowance {
    
     event MoneySent(address indexed _beneficiary, uint _amount);
     event MoneyReceived(address indexed _from, uint _amount);
     
     // money withdrawal is allowed to the owner of the smart contract or an EOA who has been assigned enough allowance
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        // check if there is enough balance in the contract
        require(_amount <= address(this).balance, "Contract doesn't own enough money");
        // if the EOA is not the owner, its allowance needed to be reduced to avoid double spending
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }
    
    //override renounceOwnership() from Ownable to disallow ownership renouncement
    function renounceOwnership() public view override onlyOwner {
        revert("Cannot renounce ownership here!");
    }
    
    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);    
    }
}