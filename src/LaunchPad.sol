// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LaunchPad {
    struct TokenLaunch {
        // uint stakedEther;
        address TokenContract;
        uint startTime;
        uint endTime;
        uint tokenToBeSupplied;
        address TokenCreator;
        uint256 minimumEther;
        uint256 AmountPerMinEth;
        uint256 AmountNeededInEth;
        uint256 TotalAmountContributed;
        mapping(address => uint) myAmount;
        mapping(address => bool) participated;
        mapping(address => bool) withdrawMyReward;
        string Name;
        bool LaunchStatus;
    }
    address Owner;
    mapping(string => TokenLaunch) tokenName;
    mapping(string => bool) exist;

    constructor() {
        Owner = msg.sender;
    }

    function registerLaunchPad(
        address _tokenContract,
        uint _tokenToBeSupplied,
        uint _startTime,
        uint _endTime,
        string memory _tokenName,
        uint256 _minimumEther,
        uint256 _amountPerMinEth,
        uint256 _amountNeededInEth
    ) external {
        _registerLaunchPad(
            _tokenContract,
            _tokenToBeSupplied,
            _startTime,
            _endTime,
            _tokenName,
            _minimumEther,
            _amountPerMinEth,
            _amountNeededInEth
        );
    }

    function _registerLaunchPad(
        address _tokenContract,
        uint _tokenToBeSupplied,
        uint _startTime,
        uint _endTime,
        string memory _tokenName,
        uint256 _minimumEther,
        uint256 _amountPerMinEth,
        uint256 _amountNeededInEth
    ) internal {
        require(_tokenContract != address(0), "THIS_IS_AN_ADDRESS_0");
        require(
            IERC20(_tokenContract).balanceOf(msg.sender) >= _tokenToBeSupplied,
            "YOU_DO_NOT_HAVE_ENOUGH_TOKEN_TO_BE_SUPPLIED"
        );

        IERC20(_tokenContract).transferFrom(
            msg.sender,
            address(this),
            _tokenToBeSupplied
        );

        TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
        _tokenLaunch.TokenContract = _tokenContract;

        _tokenLaunch.tokenToBeSupplied = _tokenToBeSupplied;

        _tokenLaunch.startTime = block.timestamp + (_startTime * 1 minutes);
        _tokenLaunch.endTime = _tokenLaunch.startTime + (_endTime * 1 minutes);
        _tokenLaunch.minimumEther = _minimumEther;
        _tokenLaunch.AmountPerMinEth = _amountPerMinEth;

        _tokenLaunch.TokenCreator = msg.sender;
        _tokenLaunch.Name = _tokenName;
        _tokenLaunch.AmountNeededInEth = _amountNeededInEth;

        exist[_tokenName] = true;
    }

    function participateInLaunchPad(
        uint256 _AmountInEther,
        string memory _tokenName
    ) public payable {
        _participateInLaunchPad(_AmountInEther, _tokenName);
    }

    function _participateInLaunchPad(
        uint256 _AmountInEther,
        string memory _tokenName
    ) internal {
        require(exist[_tokenName], "TOKEN_LAUNCH_PAD_DOES_NOT_EXIST");

        TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
        require(
            block.timestamp >= _tokenLaunch.startTime,
            "LAUNCH_HAS_NOT_STARTED"
        );
require(_tokenLaunch.participated[msg.sender] == false, "YOU_CAN_ONLY_PARTICIPATE_ONCE");
        require(
            msg.value == _AmountInEther,
            "ETHER_VALUE_MUST_BE_EQUAL_TOKEN_AMOUNT"
        );
        require(
            msg.value >= _tokenLaunch.minimumEther,
            "TOKEN_LAUNCH_CAN_NOT_BE_LESSER_THAN_MINIMUM_AMOUNT"
        );

        require(
            _AmountInEther <= _tokenLaunch.AmountNeededInEth,
            "MAXIMUM_AMOUNT_NEEDED_EXCEEDED"
        );

        require(
            _tokenLaunch.TotalAmountContributed <=
                _tokenLaunch.AmountNeededInEth,
            "TOTAL_SUPPLY_HAS_BEEN_ACHIEVED"
        );



        uint A = _tokenLaunch.TotalAmountContributed + _AmountInEther;

        require(
            A <= _tokenLaunch.AmountNeededInEth,
            "AMOUNT_INPUT_IS_GREATER_THAN_AMOUNT_LEFT"
        );
        _tokenLaunch.participated[msg.sender] = true;
        _tokenLaunch.myAmount[msg.sender] = _AmountInEther;
        _tokenLaunch.TotalAmountContributed += _AmountInEther;

    }

    function checkReward(string memory _tokenName) external view {
        _checkReward(_tokenName);
    }

    function _checkReward(
        string memory _tokenName
    ) internal view returns (uint _reward) {
        require(exist[_tokenName], "TOKEN_LAUNCH_PAD_DOES_NOT_EXIST");
        TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
        require(
            block.timestamp >= _tokenLaunch.endTime,
            "LAUNCH_HAS_NOT_ENDED"
        );
        require(
            _tokenLaunch.myAmount[msg.sender] > 0,
            "YOU_DID_NOT_PARTICIPATE"
        );
        uint Areward = _tokenLaunch.myAmount[msg.sender] /
            _tokenLaunch.minimumEther;
        return _reward = Areward * _tokenLaunch.AmountPerMinEth;
    }

    function withdrawTokenReward(string memory _tokenName) external {
        _withdrawTokenReward(_tokenName);
    }

    function _withdrawTokenReward(string memory _tokenName) internal {
        require(exist[_tokenName], "TOKEN_LAUNCH_PAD_DOES_NOT_EXIST");
        TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
        require(
            block.timestamp >= _tokenLaunch.endTime,
            "LAUNCH_HAS_NOT_ENDED"
        );

        require(
            _tokenLaunch.withdrawMyReward[msg.sender] == false,
            "YOU_HAVE_WITHDRAW_YOUR_AMOUNT"
        );
        uint tokenDetails = _tokenLaunch.myAmount[msg.sender] /
            _tokenLaunch.minimumEther;

        uint tokenToWithdraw = tokenDetails * _tokenLaunch.AmountPerMinEth;
        _tokenLaunch.withdrawMyReward[msg.sender] = true;
        IERC20(_tokenLaunch.TokenContract).transfer(
            msg.sender,
            tokenToWithdraw
        );
    }

    function withdrawEther(string memory _tokenName) external {
        _withdrawEther(_tokenName);
    }

    function _withdrawEther(string memory _tokenName) internal {
        require(exist[_tokenName], "TOKEN_LAUNCH_PAD_DOES_NOT_EXIST");
        TokenLaunch storage _tokenLaunch = tokenName[_tokenName];
        require(
            block.timestamp >= _tokenLaunch.endTime,
            "LAUNCH_HAS_NOT_ENDED"
        );
        require(
            _tokenLaunch.TotalAmountContributed > 0,
            "AMOUNT_TO_WITHDRAW_IS_ZERO"
        );
        _tokenLaunch.TotalAmountContributed = 0;

        require(
            msg.sender == _tokenLaunch.TokenCreator,
            "YOU_ARE_NOT_THE_CREATOR_OF_THIS_CONTRACT"
        );

        address payable _owner = payable(_tokenLaunch.TokenCreator);

        bool sent = _owner.send(_tokenLaunch.TotalAmountContributed);
        require(sent, "Failed to send Ether");
    }

    function emergencyWithDraw() external {
        require(Owner == msg.sender, "YOU_ARE_NOT_THE_CREATOR");
        uint balance = address(this).balance;
        bool sent = payable(msg.sender).send(balance);
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}
}
