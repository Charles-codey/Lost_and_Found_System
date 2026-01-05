# Lost and Found Smart Contract

A blockchain-based system for tracking lost and found items on campus with transparent history.

## Features

- Report lost items with detailed descriptions
- Claim found items
- Mark items as recovered
- Immutable tracking history
- Location-based reporting

## Contract Functions

### Public Functions

- `report-lost-item` - Report a lost item
- `claim-item` - Claim a lost item as found
- `mark-as-found` - Mark your reported item as recovered

### Read-Only Functions

- `get-item` - Get details of a specific item
- `get-user-report-count` - Get number of reports by user
- `get-item-nonce` - Get current item counter

## Usage

Deploy with Clarinet to enable decentralized lost and found tracking.