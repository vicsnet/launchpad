// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LaunchPad{

    struct TokenLaunch{
        // uint stakedEther;
        address TokenContract;
        uint startTime;
        uint endTime;
        uint tokenToBeSupplied;
        address TokenCreator;
        uint minimumEther;
        uint AmountPerMinEth;
        uint TotalAmountContributed;
        mapping(address => uint) myAmount;
        mapping(address => bool) withdrawMyReward;
        string Name;
    }
    address Owner;
    mapping(string => TokenLaunch) tokenName;
    constructor(){

        Owner = msg.sender;
    }


    function registerLaunchPad (address _tokenContract, uint _tokenToBeSupplied, uint _startTime, uint _endTime, string memory _tokenName, uint _minimumEther, uint _amountPerMinEth) external{
_registerLaunchPad(_tokenContract, _tokenToBeSupplied, _startTime, _endTime, _tokenName,  _minimumEther, _amountPerMinEth);

}

function _registerLaunchPad (address _tokenContract, uint _tokenToBeSupplied, uint _startTime, uint _endTime, string memory _tokenName,  uint _minimumEther, uint _amountPerMinEth) internal{

    require(_tokenContract != address(0), "THIS_IS_AN_ADDRESS_0");
require(IERC20(_tokenContract).balanceOf(msg.sender) >= _tokenToBeSupplied, "YOU_DO_NOT_HAVE_ENOUGH_TOKEN_TO_BE_SUPPLIED");

IERC20(_tokenContract).approve(address(this),_tokenToBeSupplied);

IERC20(_tokenContract).transfer(address(this), _tokenToBeSupplied);

TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
 _tokenLaunch.TokenContract = _tokenContract ;

_tokenLaunch.tokenToBeSupplied = _tokenToBeSupplied;

 _tokenLaunch.startTime = _startTime;

_tokenLaunch.endTime = _endTime;
_tokenLaunch.minimumEther = _minimumEther;
_tokenLaunch.AmountPerMinEth = _amountPerMinEth;


_tokenLaunch.TokenCreator = msg.sender;
_tokenLaunch.Name = _tokenName;


}

function participateInLaunchPad(uint _AmountInEther, string memory _tokenName) payable public{
_participateInLaunchPad(_AmountInEther, _tokenName);

}


function _participateInLaunchPad(uint _AmountInEther, string memory _tokenName) internal{
    TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
    // require(_tokenLaunch.Name == _tokenName, "");

require(msg.value == _AmountInEther, "ETHER_VALUE_MUST_BE_EQUAL_TOKEN_AMOUNT");
require(msg.value >=_tokenLaunch.minimumEther, "TOKEN_LAUNCH_CAN_NOT_BE_LESSER_THAN_MINIMUM_AMOUNT");
 
 _tokenLaunch.myAmount[msg.sender] = _AmountInEther;
 _tokenLaunch.TotalAmountContributed += _AmountInEther;
}

function checkReward(string memory _tokenName) external{
   _checkReward(_tokenName);
}

function _checkReward(string memory _tokenName) internal view returns(uint _reward){
    TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
    require(_tokenLaunch.myAmount[msg.sender]>0 , "YOU_DID_NOT_PARTICIPATE");
    _reward =  _tokenLaunch.myAmount[msg.sender];

}

function withdrawTokenReward(string memory _tokenName) external{
_withdrawTokenReward(_tokenName);

}
function _withdrawTokenReward(string memory _tokenName) internal{
      TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
require(_tokenLaunch.withdrawMyReward[msg.sender] == false, "YOU_HAVE_WITHDRAW_YOUR_AMOUNT");
      uint tokenDetails = _tokenLaunch.myAmount[msg.sender]/_tokenLaunch.minimumEther;

      uint tokenToWithdraw = tokenDetails * _tokenLaunch.AmountPerMinEth;
        _tokenLaunch.withdrawMyReward[msg.sender] = true;
      IERC20(_tokenLaunch.TokenContract).transfer(msg.sender, tokenToWithdraw);
}

function withdrawEther(string memory _tokenName) external{
   _withdrawEther(_tokenName);
}

function _withdrawEther(string memory _tokenName) internal{
    TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
    require(_tokenLaunch.TotalAmountContributed > 0, "AMOUNT_TO_WITHDRAW_IS_ZERO");
    _tokenLaunch.TotalAmountContributed = 0;

    require(msg.sender == _tokenLaunch.TokenCreator, "YOU_ARE_NOT_THE_CREATOR_OF_THIS_CONTRACT" );

    address payable _owner = payable (_tokenLaunch.TokenCreator);

        bool sent = _owner.send(_tokenLaunch.TotalAmountContributed );
        require(sent, "Failed to send Ether");
}

function emergencyWithDraw(address payable _to) external{
    require(Owner == msg.sender, "YOU_ARE_NOT_THE_CREATOR");
      bool sent = _to.send(msg.value);
      require(sent, "Failed to send Ether");
}


receive() external payable {}


}