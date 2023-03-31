// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LaunchPad.sol";
import "./mock/Token.sol";

contract LaunchPadTest is Test {
    LaunchPad public launchPad;
    Token public token;

    address vince = vm.addr(0x1);
    address dunni = vm.addr(0x2);
    address idogwu = vm.addr(0x3);
    address kenny = vm.addr(0x4);
    address faith = vm.addr(0x5);

    function setUp() public {
        vm.prank(vince);
        launchPad = new LaunchPad();
        token = new Token();
    }

function testRegisterLauncPad() public{
    vm.deal(vince, 1 ether);
vm.startPrank(vince);
token.mintToken(); 
token.balanceOf(vince);
token.approve(address(launchPad), 30000);

launchPad.registerLaunchPad(address(token), 30000, 3, 5, "VINT", 0.1 ether, 20,  2.5 ether);
        vm.stopPrank();

        token.balanceOf(address(launchPad));
    }

function testparticipateInLaunchPad() public{
    testRegisterLauncPad();
   vm.deal(dunni, 4 ether); 
   vm.warp(4 minutes);
    vm.prank(dunni);
    launchPad.participateInLaunchPad{value: 1 ether}(1 ether, "VINT");

      vm.deal(idogwu, 3 ether); 
vm.prank(idogwu);
    launchPad.participateInLaunchPad{value: 0.5 ether}(0.5 ether, "VINT");

      vm.deal(kenny, 2 ether); 
// vm.prank(kenny);
//     launchPad.participateInLaunchPad{value: 1.1 ether}(1.1 ether, "VINT");

//  vm.prank(dunni);
//     launchPad.participateInLaunchPad{value: 0.5 ether}(0.5 ether, "VINT");
}

function testCheckReward() public{
    testparticipateInLaunchPad();
       vm.warp(12 minutes);
vm.prank(dunni);
launchPad.checkReward("VINT");
}
   
   function testWithdrawTokenReward() public{
    testCheckReward();
    vm.prank(dunni);
    launchPad.withdrawTokenReward("VINT");
    token.balanceOf(dunni);
   }

   function testWithdrawEther() public{
    testWithdrawTokenReward();

    vm.prank(vince);
    // launchPad.withdrawEther("VINT");

    launchPad.emergencyWithDraw();
   }
}
