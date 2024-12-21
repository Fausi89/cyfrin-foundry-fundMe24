// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 10e18
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    } // setUp always runs first

    function testUserCanFundInteractions() public {
        //Arrange
        FundFundMe fundFundMe = new FundFundMe();
        //Act
        vm.prank(USER);
        fundFundMe.fundFundMe(address(fundMe));
        //Assert
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); //check USER is registered as a funder

        //Withdraw Arrange
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        //Withdraw Act
        vm.prank(msg.sender);
        withdrawFundMe.withdrawFundMe(address(fundMe)); //withdraw
        //Withdraw Assert
        assertEq(address(fundMe).balance, 0); //check funds were withdrawn
    }
}
