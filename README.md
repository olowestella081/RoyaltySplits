# RoyaltySplits

A blockchain-based royalty management protocol that enables creators to register works, define split payouts, and distribute earnings to collaborators transparently and automatically — all on-chain.

---

## Overview

RoyaltySplits includes a single core smart contract written in Clarity that facilitates decentralized royalty distribution for music, media, and digital works:

1. **Royalty Splits Contract** – Registers creative works, defines payout splits using basis points, accepts deposits, and allows collaborators to claim their share of earnings securely and transparently.

---

## Features

- **On-chain work registration** by creators  
- **Basis point-based royalty splits** among multiple recipients  
- **Deposit tracking** per work and split version  
- **Claimable balances** for each collaborator  
- **Ownership transfer** support for works  
- **Immutable payout history** even after split changes  
- **Permission checks** to restrict unauthorized updates  

---

## Smart Contract

### Royalty Splits Contract
- Register a work with a unique `work-id`
- Set recipients and their basis point allocations (must total 10,000)
- Deposit funds into a specific work ID
- Automatically allocates deposit shares based on current splits
- Allow recipients to claim their balance at any time
- Support versioned splits to preserve payout history
- Transfer work ownership to another principal

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/royalty-splits.git
   ```
3. Install dependencies:
    ```bash
    npm install
    ```
4. Run tests:
    ```bash
    npm test
    ```
5. Deploy contracts:
    ```bash
    clarinet deploy
    ```

--- 

## Usage

The royalty-splits.clar contract is deployed independently and can be integrated with external platforms for music streaming, NFT minting, or digital sales.
Each deposit to a work triggers internal allocation to registered recipients. Recipients can claim balances anytime.

Refer to the contract and test files for usage patterns and integration examples.

---

## License

MIT License