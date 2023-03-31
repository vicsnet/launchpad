// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract Token is ERC20{

    constructor() ERC20("VINT","VIT"){
        
    }
    function mintToken() public{
        _mint(msg.sender, 300000);
    }
}