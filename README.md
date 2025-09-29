Drosera Stale Price Feed Monitor
This repository contains a Drosera Trap designed to continuously monitor a Chainlink price feed and trigger an immediate on-chain alert if the price data becomes stale for a configured period. This provides a critical, decentralized layer of protection for DeFi protocols relying on external price data.

How It Works
This project leverages the Drosera Incident Response Protocol to provide automated security monitoring.

Data Collection (collect()): The trap fetches the updatedAt timestamp from the specified Chainlink price feed every block.

Incident Check (check()): It compares the updatedAt timestamp with the current block.timestamp. If the time difference exceeds the defined stale threshold (3600 seconds or 1 hour), the condition is met.

On-Chain Response (shouldRespond()): The trap signals the Drosera Relay to execute a function on a separate, deployed Notifier Contract, logging the stale feed's address and timestamp via an event.

Project Structure
File	- Type	- Description
StalePriceFeedTrap.sol	Drosera Trap	The core logic. Collects the timestamp and checks for staleness against a 1-hour threshold.
PriceFeedNotifier.sol	Response Contract	The target contract that receives the alert from the Drosera Relay and emits a PriceFeedIsStale event.
MockAggregatorOracle.sol	Testing Mock	A deployable mock for the Chainlink Aggregator V3 interface, used for testing and deployment on testnets (like Hoodi).
drosera.toml	Configuration	Defines the execution parameters, targets the response contract, and specifies the network settings.

Contract Details
StalePriceFeedTrap.sol
Monitored Feed: 0xfb3B397F3D52E214630DECE30a4C6cF2563Fc24A (This should be replaced with a production Chainlink address when moving off-testnet).

Stale Threshold: 3600 seconds (1 hour).

PriceFeedNotifier.sol
This contract defines the alert mechanism. Any monitoring system (like a custom bot or dashboard) can subscribe to this event to trigger off-chain alerts or on-chain governance actions.

Solidity

event PriceFeedIsStale(
    address indexed feedAddress,
    uint256 lastUpdateTimestamp,
    uint256 flaggedAtTimestamp
);

Drosera Configuration (drosera.toml)
The Drosera setup is configured to run on the Hoodi Testnet.

Parameter	Value	Role
response_contract	0xbfb1e09454df1f9c85ddb867781154f0217e1931	Address of the deployed PriceFeedNotifier.sol.
response_function	flagStalePriceFeed(address,uint256)	The function to be called by the Drosera Relay.
cooldown_period_blocks	30	Minimum 30 blocks between successful response calls.
private_trap	true	Limits access to the trap logic.
whitelist	["0x703D42F8792C0c6B47F9b8085a13ab05b5E3eF69"]	List of approved Drosera Operator addresses.

Setup & Deployment
Foundry was used for compilation.

1. Compile Contracts
Ensure you run the build command from the root of your project directory:

Bash

forge build
2. Deploy Response Contract
The PriceFeedNotifier.sol contract must be deployed on-chain before the trap is registered.

Deploy PriceFeedNotifier.sol to the Hoodi Testnet.

Update the response_contract field in drosera.toml with the deployed address.

3. Deploy/Apply the Trap
Use the Drosera CLI to register the trap configuration with the network.

Bash

# Ensure your private key is available as an environment variable
# and run from the project root.
drosera apply
4. Test Locally
You can simulate the trap's behavior against a local fork before deployment:

Bash

drosera dryrun
