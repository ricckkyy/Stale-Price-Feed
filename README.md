
This is a comprehensive README.md detailing the purpose, components, and configuration of your Stale Price Feed Trap.

Drosera Stale Price Feed Trap
This repository contains a Drosera Trap designed to monitor a Chainlink price feed and trigger an alert if the feed's data becomes stale (i.e., not updated) for a configured period. The alert is sent as an on-chain event to a designated notifier contract, allowing off-chain systems or governance mechanisms to react immediately.

Project Components
The solution consists of three main parts:

1. StalePriceFeedTrap.sol (The Trap Logic)
This contract implements the ITrap interface.

Function	Purpose	Logic
collect()	Data Collection	Fetches and returns the updatedAt timestamp from the specified Chainlink price feed.
check(data)	Incident Check	Compares the collected updatedAt timestamp against block.timestamp. If the difference exceeds STALE_THRESHOLD_SECONDS (1 hour/3600 seconds), it returns true.
shouldRespond()	Response Signal	Returns true to signal the Drosera Operator that a response is required. It encodes the Price Feed address and the stale timestamp for the response contract.

Export to Sheets
Key Constants:

PRICE_FEED: 0xfb3B397F3D52E214630DECE30a4C6cF2563Fc24A (The address of the Chainlink Aggregator V3 Mock on the Hoodi Testnet).

STALE_THRESHOLD_SECONDS: 3600 seconds (1 hour).

2. PriceFeedNotifier.sol (The Response Contract)
This contract is deployed on-chain and serves as the recipient of the alert from the Drosera Relay.

Function	Purpose	Logic
flagStalePriceFeed(address, uint256)	Response Execution	Receives the stale feed address and its last update timestamp from the Drosera Relay and emits a PriceFeedIsStale event.

Export to Sheets
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

Export to Sheets
Setup and Deployment
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
