//SPDX-License-Identifier:MIT
pragma solidity ^0.8.16;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // price = 2000.00000000 = *1e10 = 18 decimal places so that it is equal to 1 ETH
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethamount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 1ETH?
        // 2000_000000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        //(2000_000000000000000000*1_000000000000000000)/1e18
        // so 2000$=1ETH
        uint256 ethamountinUSD = (ethPrice * ethamount) / 1e18;
        return ethamountinUSD;
    }
}
