# MarketBTC — Bitcoin-Native Decentralized Marketplace

**MarketBTC** is a fully decentralized marketplace built on the **Stacks** blockchain that settles transactions with **Bitcoin**. It enables merchants to register and verify brands, list products for direct sale or auction, and build trust through customer reviews. The contract ensures transparent fees, automated escrow for auctions, and a reputation-driven ecosystem — all on-chain.

## Key Features

- **Bitcoin Settlement** via Stacks protocol
- **Decentralized Brand Management**  
- **Direct Sales & Auctions** with automated payment flows  
- **Transparent Platform Fees** (default 2.5%)
- **Escrow System** for secure bidding  
- **Decentralized Review System**  
- **Permissioned Brand Verification**

## Smart Contract Structure

### Constants

| Name | Type | Description |
|------|------|-------------|
| `contract-owner` | `principal` | Deployer address with admin permissions |
| Error codes | `err u100 - u109` | Custom error messages for validation & access control |
| `platform-fee` | `uint` | Platform fee rate (default: 2.5%) |

### Data Maps

- `Brands`: Maps a merchant's `principal` to their brand details.
- `Products`: Indexed by product ID, contains metadata and sale type (auction/direct).
- `Auctions`: Stores auction state, bidding info, and escrow status.
- `Reviews`: Maps `{product-id, reviewer}` to a review with rating and comment.

## Functionality

### Brand Management

- `register-brand(name)`: Register a new brand (unverified by default).
- `verify-brand(brand)`: Verify a brand (only `contract-owner`).

### Direct Sales

- `list-product(name, description, price)`: List product for fixed-price sale.
- `purchase-product(product-id)`: Purchase a product; includes automatic fee split.

### Auctions

- `create-auction(name, description, min-price, duration)`: Start an auction.
- `place-bid(product-id, bid-amount)`: Bid on an active auction.
- `end-auction(product-id)`: Finalize auction, transfer funds from escrow.

### Reviews

- `add-review(product-id, rating, comment)`: Submit a review (1–5 stars).

## Read-Only Functions

| Function | Description |
|---------|-------------|
| `get-product(product-id)` | Fetch product metadata |
| `get-brand(brand)` | Retrieve brand info |
| `get-review(product-id, reviewer)` | Fetch a specific review |
| `get-auction(product-id)` | View current auction state |

## Access Control

- **Only the `contract-owner`** can verify brands.
- Product and auction creation is restricted to **brand owners**.
- Reviews are open but **limited to one per reviewer/product**.

## Platform Fee Logic

```clarity
(let ((fee (/ (* price (var-get platform-fee)) u1000)))
```

The platform fee is deducted and transferred to the contract owner during purchases and auction finalizations. Default is 2.5% (can be adjusted in contract upgrades).

---

## Deployment & Usage

This contract is written in **Clarity** and designed for use with the **Stacks CLI** or developer tools such as [Clarinet](https://docs.hiro.so).

To deploy:

```bash
clarinet deploy
```

## Security Considerations

- Funds are escrowed during auctions to prevent fraudulent bidding.
- Reviews and ratings are immutable post-submission.
- Platform fees are collected transparently, viewable on-chain.
- Principal checks ensure only authorized accounts interact with sensitive functions.

## Future Enhancements

- NFT integration for unique product representation
- On-chain dispute resolution mechanism
- Dynamic fee adjustment
- Product category tagging and filters

## Acknowledgments

Built on [Stacks](https://stacks.co) to bring smart contracts to Bitcoin.
