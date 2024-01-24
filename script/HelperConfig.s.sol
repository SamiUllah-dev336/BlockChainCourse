// SPDX-License-Identifier: MIT
// 1- Deploy mocks when we are on a local anvil chain
// 2- keep track of contract addresses accross different chain

// Seploia ETH/USD diff add
// mainnet ETH/USD diff
pragma solidity 0.8.23;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // Magic Numbers
    uint8 public constant Decimal = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    // grab a existing address using this in a live network
    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepliaConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        // if not already created or set this below interface
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            Decimal,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilPriceFeed = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilPriceFeed;
    }
}
