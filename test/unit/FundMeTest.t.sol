// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // uint256 number = 1;

    // function setUp(address _address) external {
    //     number = 2;
    // }

    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(address(0x694AA1769357215DE4FAC081bf1f309aDC325));
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
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
        assertEq(fundMe.getOwner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 10}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier withdrawActAssert() {
        _;

        //part of Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 stratingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft(); // 1000
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //200
        fundMe.withdraw(); //should have spent gas? In anvil gas price defaults to zero.
        // uint256 gasEnd = gasleft(); //800
        // uint256 priceForGasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(priceForGasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + stratingFundMeBalance
        );
    }

    function testWithdrawWithSingleFunder() public funded withdrawActAssert {}

    function testWithdrawWithMultipleFunders() public funded withdrawActAssert {
        //Arrange
        uint160 numberOfFunders = 8;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            hoax(address(1), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
    }

    function testCheaperWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 8;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            hoax(address(1), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 stratingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + stratingFundMeBalance
        );
    }
}

// Actually when we do transactions, It costs gas. But we didn't consider it in above tests. How could they pass?
//vm.startPrank() , vm.stopPrank()
