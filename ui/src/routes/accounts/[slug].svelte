<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressTemplateNFT, addressArbazaar } from '../../../config';
    import Copy from '$lib/components/Copy.svelte';
    import Grid from '$lib/components/Grid.svelte';
    import NFT from '$lib/components/NFT.svelte';
    import InfiniteLoading from 'svelte-infinite-loading';

    let loading = true;

    let address = ``;
    let listings = [];
    let nfts = [];
    let sales = [];

    const effect = `wave`;

    let index = 0;

    /* A more reliable and decentralized solution for fetching data is a high-priority upcoming feature. */
    const COVALENT_KEY = `ckey_f02916bdd2b04038bc0808fb3bc`;

    let i = 0;

    const load = async () => {
        try {
            /* Get current Arbazaar listings and previous NFT sales */
            await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`);
            const marketContract = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
            const data = await marketContract.methods.retrieveListingsByAccount(address).call();
            console.log(data);
            listings = await Promise.all(data.map(async (e) => {
                const price = $web3.utils.fromWei(e.price, `ether`);
                let item = {
                    collection: `Unknown Collection`,
                    id: parseInt(e.tokenId),
                    addressCollection: e.collection,
                    sold: e.sold,
                    price,
                };
                return item;
            }));

            sales = listings.filter((e) => e.sold);
            listings = listings.filter((e) => !e.sold);

            /* Get current NFTs */
            const items = await fetch(`https://api.covalenthq.com/v1/42161/address/${address}/balances_v2/?key=${COVALENT_KEY}&nft=true&no-nft-fetch=true`);
            const jsonItems = await items.json();
            if (jsonItems.error === false) {
                jsonItems.data.items.forEach((item) => {
                    if (typeof item.nft_data !== `undefined`) {
                        if (item.nft_data !== null) {
                            item.nft_data.forEach((nft) => {
                                nfts.push({
                                    collection: item.contract_name,
                                    id: nft.token_id,
                                    addressCollection: item.contract_address,
                                });
                                nfts = nfts; // Svelte glitch
                            });
                        }
                    }
                });
            } else {
                console.log(`ERROR`);
            }
        } catch (e) {
            console.log(`ERROR: `, e.message);
        }
    };

    onMount(() => {
        try {
            address = $page.path.replace(`/accounts/`, ``);
            address = address.replace(`/`, ``);
            load();
        } catch (e) {
            //goto(`/`);
        }
    });
</script>

<svelte:head>
    <title>My Account - Arbazaar</title>
</svelte:head>

<h1 class="name">{address}</h1>
<p class="address">
    <a href="https://arbiscan.io/token/{address}" rel="external noopener" target="_blank">
        {address}
    </a>
    <Copy text={address} />
</p>

{#if listings.length > 0}
    <h2>Listings</h2>
    <Grid fullbleed="true">
        {#each listings as nft}
            <NFT
                collection={nft.collection}
                id={nft.id}
                addressCollection={nft.addressCollection}
            />
        {/each}
        {#if loading === false}
            <InfiniteLoading spinner="circles" on:infinite={infiniteHandler} />
        {/if}
    </Grid>
{/if}

<h2>NFTs</h2>

{#if nfts.length > 0}
    <Grid fullbleed="true">
        {#each nfts as nft}
            <NFT
                collection={nft.collection}
                id={nft.id}
                addressCollection={nft.addressCollection}
            />
        {/each}
        {#if loading === false}
            <InfiniteLoading spinner="circles" on:infinite={infiniteHandler} />
        {/if}
    </Grid>
{:else}
    <p>We could not find any NFTs on Arbitrum owned by this account.</p>
{/if}

{#if sales.length > 0}
    <h2>Sales</h2>
    <Grid fullbleed="true">
        {#each sales as nft}
            <NFT
                collection={nft.collection}
                id={nft.id}
                addressCollection={nft.addressCollection}
            />
        {/each}
        {#if loading === false}
            <InfiniteLoading spinner="circles" on:infinite={infiniteHandler} />
        {/if}
    </Grid>
{/if}

<style>
    .image {
        border-radius: 50%;
        height: 128px;
        margin-top: 30px;
        width: 128px;
    }
    .name {
        font-size: 40px;
        font-weight: 600;
    }
    .lastUpdated {
        color: #ddd;
        time {
            color: var(--fg);
        }
    }
    .description {
        line-height: 1.5;
    }
    .details {
        align-items: center;
        display: flex;
        flex-direction: column;
        justify-content: center;
        row-gap: 16px;
        .details__item {
            background-color: var(--bg-hover);
            border: 1px solid #ddd;
            border-radius: 16px;
            padding: 8px 0;
            width: 150px;
            p {
                margin: 0;
            }
            .details__val {
                font-weight: 700;
                font-size: 26px;
            }
            .details__key {
                color: #ddd;
                font-size: 14px;
                margin-top: 4px;
            }
        }
    }
    .flex {
        align-items: center;
        column-gap: 8px;
        display: flex;
        justify-content: center;
    }
    @media screen and (min-width: 768px) {
        .details {
            flex-direction: row;
            .details__item {
                border-radius: 0;
                &:first-child {
                    border-radius: 16px 0 0 16px;
                }
                &:last-child {
                    border-radius: 0 16px 16px 0;
                }
            }
        }
    }
</style>
