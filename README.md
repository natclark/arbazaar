# arbazaar

This project is a monorepo for the Arbazaar core `protocol` and official Arbazaar front-end `ui` implementation.

The `ui` repo is synced with https://arbazaar.pages.dev.

https://arbazaar.io is the canonical alias of https://arbazaar.pages.dev.

## Setup

Add `pnpm`:

```sh
npx pnpm add -g pnpm
```

Install packages:

```sh
npx pnpm i
```

## Protocol

### Develop

First, start a local JSON-RPC serve:

```sh
npx pnpm run protocol:node
```

Then, deploy the contracts on your local Hardhat chain:

```sh
npx pnpm run protocol:dev
```

Lastly, send yourself some local ETH to play with:

```sh
npx hardhat --network localhost faucet <address>
```

**The above command must be run within the `protocol/` directory. Be sure to replace `<address>` with your Ethereum address.**

### Build

Compile the contracts:

```sh
npx pnpm run protocol:build
```

### Deploy

Deploy on Arbitrum One:

```sh
npx pnpm run protocol:one
```

Deploy on Arbitrum Rinkeby testnet:

```sh
npx pnpm run protocol:rinkeby
```

## UI

### Develop

```sh
npx pnpm run ui:dev
```

### Build

```sh
npx pnpm run ui:build
```

### Preview

```sh
npx pnpm run ui:preview
```

## License

[MIT](https://github.com/natclark/arbazaar/blob/master/LICENSE)
