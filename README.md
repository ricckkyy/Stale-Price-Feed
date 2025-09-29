
This is a comprehensive README.md detailing the purpose, components, and configuration of your Stale Price Feed Trap.

Drosera Stale Price Feed Monitor
This repository contains a Drosera Trap designed to continuously monitor a Chainlink price feed and trigger an immediate on-chain alert if the price data becomes stale for a configured period. This provides a critical, decentralized layer of protection for DeFi protocols relying on external price data.

How It Works
This project leverages the Drosera Incident Response Protocol to provide automated security monitoring.

Data Collection (collect()): The trap fetches the updatedAt timestamp from the specified Chainlink price feed every block.

Incident Check (check()): It compares the updatedAt timestamp with the current block.timestamp. If the time difference exceeds the defined stale threshold (3600 seconds or 1 hour), the condition is met.

On-Chain Response (shouldRespond()): The trap signals the Drosera Relay to execute a function on a separate, deployed Notifier Contract, logging the stale feed's address and timestamp via an event.

Project Structure
File - 	Type - 	Description
StalePriceFeedTrap.sol 	Drosera Trap	The core logic. Collects the timestamp and checks for staleness against a 1-hour threshold.
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
🛠️ Setup & Deployment
This project assumes you are using Foundry for compilation.

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

This is a comprehensive README.md for your Drosera project, detailing the purpose, components, and configuration of your Stale Price Feed Trap.

🛡️ Drosera Stale Price Feed Trap
This repository contains a Drosera Trap designed to monitor a Chainlink price feed and trigger an alert if the feed's data becomes stale (i.e., not updated) for a configured period. The alert is sent as an on-chain event to a designated notifier contract, allowing off-chain systems or governance mechanisms to react immediately.

🏗️ Project Components
The solution consists of three main parts:

1. StalePriceFeedTrap.sol (The Trap Logic)
This contract implements the ITrap interface.

Function	Purpose	Logic
collect()	Data Collection	Fetches and returns the updatedAt timestamp from the specified Chainlink price feed.
check(data)	Incident Check	Compares the collected updatedAt timestamp against block.timestamp. If the difference exceeds STALE_THRESHOLD_SECONDS (1 hour/3600 seconds), it returns true.
shouldRespond()	Response Signal	Returns true to signal the Drosera Operator that a response is required. It encodes the Price Feed address and the stale timestamp for the response contract.
Key Constants:

PRICE_FEED: 0xfb3B397F3D52E214630DECE30a4C6cF2563Fc24A (The address of the Chainlink Aggregator V3 Mock on the Hoodi Testnet).

STALE_THRESHOLD_SECONDS: 3600 seconds (1 hour).

2. PriceFeedNotifier.sol (The Response Contract)
This contract is deployed on-chain and serves as the recipient of the alert from the Drosera Relay.

Function	Purpose	Logic
flagStalePriceFeed(address, uint256)	Response Execution	Receives the stale feed address and its last update timestamp from the Drosera Relay and emits a PriceFeedIsStale event.
The event structure provides immediate, easily indexable data for off-chain monitoring systems (like The Graph, a custom bot, or a governance dashboard).

3. drosera.toml (The Configuration File)
This file defines how the Drosera Network should execute and manage the trap.

Parameter	Value	Description
path	"out/StalePriceFeedTrap.sol/StalePriceFeedTrap.json"	Location of the compiled trap bytecode (Foundry build path).
response_contract	"0xbfb1e09454df1f9c85ddb867781154f0217e1931"	The address of the deployed PriceFeedNotifier contract.
response_function	"flagStalePriceFeed(address,uint256)"	The function signature to call on the response contract.
cooldown_period_blocks	30	Prevents the trap from alerting more than once every 30 blocks.
private_trap	true	The trap is private, limiting execution to only whitelisted Operators.
whitelist	["0x703D42F8792C0c6B47F9b8085a13ab05b5E3eF69"]	List of authorized Operator addresses.
🚀 Setup and Deployment
Prerequisites
Foundry: For compiling your Solidity code (forge build).

Drosera CLI: For configuring and deploying the trap (drosera apply).

Steps
Compile the Contracts:

Bash

forge build
(Ensure this succeeds and the artifacts appear in the out/ directory).

Deploy the Notifier Contract:
Deploy PriceFeedNotifier.sol to the Hoodi testnet (e.g., via Remix or a Hardhat/Foundry script) and update the response_contract address in drosera.toml with the deployed address.

Deploy the Trap Configuration:
Ensure your drosera.toml is correctly configured and run the drosera apply command from your project root to register the trap with the network.

Bash

drosera apply
Testing (Dryrun):
You can test your trap logic locally against a fork before deployment.

Bash

# Run this command from the project root directory
drosera dryrun

How It Works
This trap provides essential defensive monitoring for any DeFi protocol that relies on Chainlink for price data.

Continuous Monitoring: Drosera Operators constantly call collect() to get the latest timestamp.

Incident Detection: Operators call check() on the collected data. If the time difference between the current block and the last price update is greater than 1 hour, an incident is detected.

On-Chain Alert: Drosera calls shouldRespond(), which instructs the Drosera Relay to execute the flagStalePriceFeed function on the PriceFeedNotifier contract, emitting a real-time event signal.
