// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/LaunchPad.sol";

contract LaunchPadDeploy is Script {

      uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        LaunchPad launchpad;
    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        launchpad = new LaunchPad();
        vm.stopBroadcast();
    }
}
