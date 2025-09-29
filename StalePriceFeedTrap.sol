// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IChainlinkAggregatorV3 {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract StalePriceFeedTrap is ITrap {
    IChainlinkAggregatorV3 internal constant PRICE_FEED =
        IChainlinkAggregatorV3(0xfb3B397F3D52E214630DECE30a4C6cF2563Fc24A);

    uint256 internal constant STALE_THRESHOLD_SECONDS = 3600;

    function collect() external view returns (bytes memory) {
        (, , , uint256 updatedAt, ) = PRICE_FEED.latestRoundData();
        return abi.encode(updatedAt);
    }

    function check(bytes calldata data) external view returns (bool) {
        uint256 updatedAt = abi.decode(data, (uint256));
        return (block.timestamp - updatedAt) > STALE_THRESHOLD_SECONDS;
    }

    function shouldRespond(bytes[] calldata collectedData)
        external
        pure
        returns (bool, bytes memory)
    {
        if (collectedData.length == 0) {
            return (false, "");
        }

        uint256 updatedAt = abi.decode(collectedData[0], (uint256));

        bool should_respond = true;

        bytes memory response_data = abi.encode(
            address(PRICE_FEED),
            updatedAt
        );

        return (should_respond, response_data);
    }
}


