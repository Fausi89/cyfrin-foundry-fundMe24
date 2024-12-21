// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// 3- Sepolia ETH/USD and Mainnet ETH/USD have different addresses

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil, we will deploy mocks
    // otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    // struct to create a type
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSpoliaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = MainnetEthConfig();
        } else {
            revert("Not a valid network");
        }
    }

    function getSpoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address of Spolia ETH/USD
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // price feed address of Anvil ETH/USD
        // 1. deploy the mocks
        // 2. return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } // to prevent creating new pricefeed contract

        vm.startBroadcast(); // since we are using VM we cant use public pure
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // mock takes these values(decimals and initinal price)
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }

    function MainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address of Spolia ETH/USD
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }
}
