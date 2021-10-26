<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import ERC721 from '$lib/abi/ERC721';
    import wallet from '$lib/stores/wallet';
    import { SkeletonText, SkeletonBlock, SkeletonImage, SkeletonAvatar } from 'skeleton-elements/svelte';
    import Copy from '$lib/components/Copy.svelte';
    import Grid from '$lib/components/Grid.svelte';
    import NFT from '$lib/components/NFT.svelte';
    import InfiniteLoading from 'svelte-infinite-loading';

    let loading = true;

    let address = ``;
    let banner = ``;
    let image = ``;
    let name = ``;
    let updatedAt = ``;
    let description = ``;
    let supply = 0;
    let owners = 0;
    let floor = `N/A`;
    let volume = 0;
    let nfts = [];

    const effect = `wave`;

    let index = 0;

    /* A more reliable and decentralized solution for fetching data is a high-priority upcoming feature. */
    const COVALENT_KEY = `ckey_f02916bdd2b04038bc0808fb3bc`;

    const firstLoad = () => {
        return new Promise(async (resolve, reject) => {
            await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`);
            const contract = new $web3.eth.Contract(ERC721.abi, address);
            contract.methods.name().call().then((result) => {
                name = result;
                contract.methods.totalSupply().call().then((result) => {
                    supply = result;
                    loading = false;
                    resolve(true);
                });
            });
            const items = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${address}/nft_token_ids/?key=${COVALENT_KEY}`);
            const jsonItems = await items.json();
            if (jsonItems.error === false) {
                updatedAt = jsonItems.data.updated_at;
            } else {
                console.log(`ERROR`);
            }
            const metadata = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${address}/nft_metadata/0/?key=${COVALENT_KEY}`);
            const jsonMetadata = await metadata.json();
            if (jsonMetadata.error === false) {
                console.log(jsonMetadata);
                const data = jsonMetadata.data.items[0].nft_data[0];
                console.log(data);
                banner = data.external_data.image;
                if (banner.includes(`http`) === false) {
                    banner = `https://cloudflare-ipfs.com/ipfs/${image}`;
                }
                image = data.external_data.image;
                if (image.includes(`http`) === false) {
                    image = `https://cloudflare-ipfs.com/ipfs/${image}`;
                }
                description = data.external_data.description;
            } else {
                console.log(`ERROR`);
            }
            const holders = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${address}/token_holders/?key=${COVALENT_KEY}`);
            const jsonHolders = await holders.json();
            if (jsonHolders.error === false) {
                owners = jsonHolders.data.pagination.total_count;
            } else {
                console.log(`ERROR`);
            }
        });
    };

    let i = 0;

    const load = () => {
        console.log(`loadin`);
        return new Promise(async (resolve, reject) => {
            const nextTwelve = i + 12;
            for (i = i; i < nextTwelve; i++) {
                if (i < supply) {
                    nfts.push({
                        collection: collections[index].name,
                        id: i,
                        addressCollection: address,
                    });
                    console.log(nfts);
                    nfts = nfts; // Svelte glitch
                    i === nextTwelve - 1 && (resolve(true));
                } else {
                    resolve(false);
                }
            };
        });
    };

    const infiniteHandler = ({ detail: { loaded, complete, }, }) => {
        load()
            .then((response) => !!response ? loaded() : complete())
            .catch(() => complete());
    };

    onMount(() => {
        try {
            address = $page.path.replace(`/collection/`, ``);
            address = address.replace(`/`, ``);
            index = collections.indexOf(collections.find((e) => e.address === address));
            console.log(index);
            firstLoad()
                .then((response) => load());
        } catch (e) {
            //goto(`/`);
        }
    });
</script>

<svelte:head>
    <title>{name} NFT Collection - Arbazaar</title>
</svelte:head>

{#if image === ``}
    <SkeletonImage {effect} height={128} width={128} borderRadius="50%" />
{:else}
    <img class="image" src={image} alt="{name} Logo" loading="lazy">
{/if}
<h1 class="name">{name}</h1>
<p class="lastUpdated">Last updated: <time datetime={updatedAt}>{new Date(updatedAt).toLocaleDateString(undefined, { day: `numeric`, hour: `numeric`, month: `long`, year: `numeric`, })}</time></p>
<p class="description">{description}</p>
<div class="details">
    <div class="details__item">
        <p class="details__val">{supply}</p>
        <p class="details__key">items</p>
    </div>
    <div class="details__item">
        <p class="details__val">{owners}</p>
        <p class="details__key">owners</p>
    </div>
    <div class="details__item">
        <div class="flex">
            <img class="eth" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy">
            <p class="details__val">{floor}</p>
        </div>
        <p class="details__key">floor price</p>
    </div>
    <div class="details__item">
        <div class="flex">
            <img class="eth" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy">
            <p class="details__val">{volume}</p>
        </div>
        <p class="details__key">volume traded</p>
    </div>
</div>
<p class="address">
    <a href="https://arbiscan.io/token/{address}" rel="external noopener" target="_blank">
        {address}
    </a>
    <Copy text={address} />
</p>

<Grid fullbleed="true">
    {#each nfts as nft}
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
