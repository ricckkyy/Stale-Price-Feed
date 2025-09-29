// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. The minimal interface for Chainlink AggregatorV3
interface IAggregatorV3Interface {
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
        
    function decimals() external view returns (uint8);
}

// 2. The Mock Contract
contract MockAggregatorV3 is IAggregatorV3Interface {
    
    // State variables to hold the mock data
    int256 public latestAnswer;
    uint256 public latestUpdatedAt;

    // Use a fixed constant that matches Chainlink's standard for ETH/USD (8 decimals)
    uint8 private constant DECIMALS_VALUE = 8; 
    uint80 private constant MOCK_ROUND_ID = 1;

    // Constructor to set an initial price
    constructor(int256 initialAnswer) {
        latestAnswer = initialAnswer;
        latestUpdatedAt = block.timestamp;
    }

    // --- Control Functions for Testing ---

    function setLatestAnswer(int256 _answer) public {
        latestAnswer = _answer;
        latestUpdatedAt = block.timestamp;
    }
    
    function setLatestTimestamp(uint256 _timestamp) public {
        latestUpdatedAt = _timestamp;
    }

    // --- Interface Implementation ---

    /
     * @notice Implements the required Chainlink interface function: latestRoundData()
     * @dev Provides the mock price and the controlled timestamp.
     */
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (
            MOCK_ROUND_ID,
            latestAnswer,
            block.timestamp, // StartedAt is usually block.timestamp
            latestUpdatedAt, // This is the crucial variable for your staleness check
            MOCK_ROUND_ID
        );
    }
    
    /
     * @notice Implements the required Chainlink interface function: decimals()
     * @dev Forcing this to 'pure' is a common fix for interface compilation issues.
     */
    function decimals() external pure override returns (uint8) {
        return DECIMALS_VALUE;
    }
}
