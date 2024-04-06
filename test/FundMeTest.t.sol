// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // uint256 number = 1;

    // function setUp(address _address) external {
    //     number = 2;
    // }

    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(address(0x694AA1769357215DE4FAC081bf1f309aDC325));
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    // function testDemo() public view {
    //     console.log(number);
    //     console.log("hello !!!!!");
    //     assertEq(number, 2);
    // }

    // function testDemoTest() public view {
    //     assertEq(number, 2);
    // }

    function testMinimumUsdValue() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
