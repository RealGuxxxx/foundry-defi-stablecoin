// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 3000e8;
    int256 public constant BTC_USD_PRICE = 100000e8;

    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        if (activeNetworkConfig.weth != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_PRICE);
        ERC20Mock wethMock = new ERC20Mock();

        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(DECIMALS, BTC_USD_PRICE);
        ERC20Mock wbtcMock = new ERC20Mock();
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: address(ethUsdPriceFeed), 
            wbtcUsdPriceFeed: address(btcUsdPriceFeed),
            weth: address(wethMock),
            wbtc: address(wbtcMock)
        });
    }
}