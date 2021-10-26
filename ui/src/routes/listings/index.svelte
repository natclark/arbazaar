<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressTemplateNFT, addressArbazaar } from '../../../config';
    import { SkeletonText, SkeletonBlock, SkeletonImage, SkeletonAvatar } from 'skeleton-elements/svelte';
    import Copy from '$lib/components/Copy.svelte';
    import Grid from '$lib/components/Grid.svelte';
    import NFT from '$lib/components/NFT.svelte';
    import InfiniteLoading from 'svelte-infinite-loading';

    let loading = true;

    let listings = [];

    const effect = `wave`;

    onMount(async () => {
        try {
            await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`);
            const marketContract = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
            const data = await marketContract.methods.retrieveListingsActive().call();
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

            listings = listings; // Svelte glitch
        } catch (e) {
            console.log(`ERROR: `, e.message);
        }
    });
</script>

<svelte:head>
    <title>Listings - Arbazaar</title>
</svelte:head>

<h1>Active Arbazaar Listings</h1>

{#if listings.length > 0}
    <Grid fullbleed="true">
        {#each listings as nft}
            <NFT
                collection={nft.collection}
                id={nft.id}
                addressCollection={nft.addressCollection}
            />
        {/each}
        {#if loading === false}
            <InfiniteLoading on:infinite={infiniteHandler} />
        {/if}
    </Grid>
{:else}
    <p>Looks like there aren't any listings right now!</p>
    <p>We've just launched, so hang in there...</p>
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
