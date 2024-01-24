//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTest is Test {
    // uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 private constant send_value = 0.1 ether;
    uint256 private constant Starting_balance = 10 ether;
    uint256 public constant Gas_Price = 1;

    function setUp() external {
        // number = 2;
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, Starting_balance); // this will set the starting balance
    }

    function testMinimumUSDisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        console.log("i am sami", fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundsFailsNotEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundeDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, send_value);
    }

    function testAddsFundersToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // the next tx will be sent using this user  but error user not have money , we create a new balance or money using cheatcode
        fundMe.fund{value: send_value}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert(); // If i not enter this statment then next statement is failed , it is correct because it is not  a owner ,This statment fails the next statment
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        //uint256 gasStart = gasleft();
        //vm.txGasPrice(Gas_Price);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10; // 160 to generate addresses using numbers... as address(1)
        uint160 fundersInitialIndex = 2;

        for (uint160 i = fundersInitialIndex; i < numberOfFunders; i++) {
            // vm.prank
            // vm.deal
            // combine of both is hoax hoax(<someaddress>,send_value);
            hoax(address(i), send_value);
            fundMe.fund{value: send_value}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
        console.log(fundMe.getOwner().balance);
    }

    function testWithDrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10; // 160 to generate addresses using numbers... as address(1)
        uint160 fundersInitialIndex = 2;

        for (uint160 i = fundersInitialIndex; i < numberOfFunders; i++) {
            // vm.prank
            // vm.deal
            // combine of both is hoax hoax(<someaddress>,send_value);
            hoax(address(i), send_value);
            fundMe.fund{value: send_value}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
        console.log(fundMe.getOwner().balance);
    }
}
