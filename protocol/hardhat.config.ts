`use strict`;

import 'dotenv/config';
import { HardhatUserConfig } from 'hardhat/types';
import 'hardhat-deploy';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-watcher';
import './tasks/faucet.js';

declare const process : {
    env: {
        PRIVATE_KEY_ONE: string,
        PRIVATE_KEY_RINKEBY: string,
    },
};

const accountsOne = [process.env.PRIVATE_KEY_ONE];

const accountsRinkeby = [process.env.PRIVATE_KEY_RINKEBY];

const settings = {
    optimizer: {
        enabled: true,
        runs: 200,
    },
};

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
    defaultNetwork: `localhost`,
    paths: {
        sources: `./src`,
        tests: `./tests`,
    },
    networks: {
        arbitrum: {
            accounts: accountsOne,
            chainId: 42161,
            url: `https://arb1.arbitrum.io/rpc`,
        },
        arbitrumRinkeby: {
            accounts: accountsRinkeby,
            chainId: 421611,
            url: `https://rinkeby.arbitrum.io/rpc`,
        },
        localhost: {
            url: `http://127.0.0.1:8545`,
        },
        hardhat: {
            chainId: 31337,
        },
    },
    solidity: {
        compilers: [
            {
                settings,
                version: `0.8.4`,
            },
        ],
    },
    watcher: {
        watch: {
            tasks: [
                {
                    command: `run`,
                    params: {
                        script: `scripts/deploy.js`,
                    },
                }
            ],
        },
    },
};

export default config;
