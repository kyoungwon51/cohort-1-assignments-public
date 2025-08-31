// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MiniAMM} from "../src/MiniAMM.sol";
import {MockERC20} from "../src/MockERC20.sol";

import "forge-std/console.sol";

contract MiniAMMScript is Script {
    MiniAMM public miniAMM;
    MockERC20 public token0;
    MockERC20 public token1;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock ERC20 tokens
        token0 = new MockERC20("TokenX", "TKX");
        token1 = new MockERC20("TokenY", "TKY");

        // Deploy MiniAMM with the tokens
        miniAMM = new MiniAMM(address(token0), address(token1));

        vm.stopBroadcast();

        // Print deployed addresses
        console.log("MockERC20 TokenX:", address(token0));
        console.log("MockERC20 TokenY:", address(token1));
        console.log("MiniAMM:", address(miniAMM));
    }
}
