// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PriceFeedNotifier
 * @author Your Name
 * @notice This contract receives notifications from Drosera about stale Chainlink price feeds.
 */
contract PriceFeedNotifier {
    // Event to log when a price feed is flagged as stale.
    event PriceFeedIsStale(
        address indexed feedAddress,
        uint256 lastUpdateTimestamp,
        uint256 flaggedAtTimestamp
    );

    /**
     * @notice This is the response function called by the Drosera Relay.
     * @dev It emits an event logging the details of the stale price feed.
     * @param feedAddress The address of the stale price feed.
     * @param lastUpdateTimestamp The timestamp of the feed's last update.
     */
    function flagStalePriceFeed(address feedAddress, uint256 lastUpdateTimestamp)
        external
    {
        // In a production environment, you would add an access control modifier here
        // to ensure only the Drosera Relay can call this function.

        // Emit an event containing the stale feed's address and its last update time.
        emit PriceFeedIsStale(
            feedAddress,
            lastUpdateTimestamp,
            block.timestamp
        );
    }
}
