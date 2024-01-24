//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
error fundme_notOwner();

contract FundMe {
    using PriceConverter for uint256;
    // This variable is used one time so make it constant and immutable , then gas is minimum used
    // 21,415 - gas with constant
    // 23,515 - gas with non-constant
    uint256 public constant MINIMUM_USD = 5e18; // not show in a storage

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private addressToAmountFunded;

    // 21508- gas immutable
    // 23644- gas non-immutable
    // because two variables are not store in storing slot but directly in bytecode of contract so that it save gas
    address private immutable i_owner; // not show in a storage, they are part of bytecode of contract
    AggregatorV3Interface private s_priceFeed;

    // for owner of contract
    // this function is call imediatly whenever contract is deployed
    constructor(address priceFeed) {
        i_owner = msg.sender; // deployer of contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // user send at least 1eth
        // how do we send ETH to this contract
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "did'nt send enough ETH"
        );
        // msg.sender => it is a global variable
        s_funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // what is revert ?
    // Undo any actions that have been done , and send the remaining gas back

    // because storage variable use most gas.. so use it minimum , use memory
    function cheaperWithdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // These are used to send ethereum currency tokens to other contract
        //transfer
        // send
        // call
        // msg.sender is of type address and for sending blockchain ethereum , we use payable address
        // payable(msg.sender).transfer(address(this).balance); // automatically revert and use 2300 gas
        // send
        // bool sending=payable(msg.sender).send(address(this).balance);
        // require(sending,"send failed!!"); //revert and use 2300 gas
        //call= it is recommended way!!
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender==i_owner,"Must be owner");
        if (msg.sender != i_owner) {
            revert fundme_notOwner();
        }
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
