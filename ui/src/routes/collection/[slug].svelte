<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import ERC721 from '$lib/abi/ERC721';
    import wallet from '$lib/stores/wallet';
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
    <span class="skeleton-image skeleton-effect-wave">
        <svg width="128" height="128" viewBox="0 0 128 128" preserveAspectRatio="none" style="border-radius: 50%">
            <polygon fillrule="evenodd" points="0 0 128 0 128 128 0 128"></polygon>
            <path d="M40.81691428571429,88.65622857142856 L87.18308571428571,88.65622857142856 C92.78125714285713,88.65622857142856 95.59382857142856,85.87051428571428 95.59382857142856,80.35268571428571 L95.59382857142856,47.64731428571429 C95.59382857142856,42.12948571428572 92.78125714285713,39.34377142857143 87.18308571428571,39.34377142857143 L40.81691428571429,39.34377142857143 C35.24548571428572,39.34377142857143 32.406171428571426,42.10262857142857 32.406171428571426,47.64731428571429 L32.406171428571426,80.35268571428571 C32.406171428571426,85.89737142857143 35.24548571428572,88.65622857142856 40.81691428571429,88.65622857142856 Z M76.89725714285714,63.933028571428565 C75.69188571428572,62.861599999999996 74.32582857142856,62.2992 72.87942857142858,62.2992 C71.37942857142858,62.2992 70.06685714285715,62.80811428571428 68.83474285714286,63.906285714285715 L56.72754285714285,74.72765714285714 L51.77222857142857,70.22765714285714 C50.6472,69.23657142857144 49.44194285714286,68.70091428571428 48.15611428571428,68.70091428571428 C46.977599999999995,68.70091428571428 45.82582857142857,69.20982857142857 44.72754285714285,70.20091428571428 L36.71862857142857,77.4062857142857 L36.71862857142857,47.861599999999996 C36.71862857142857,45.07588571428572 38.21862857142857,43.65622857142857 40.89725714285714,43.65622857142857 L87.10251428571428,43.65622857142857 C89.75428571428571,43.65622857142857 91.28091428571429,45.07588571428572 91.28091428571429,47.861599999999996 L91.28091428571429,77.43302857142857 L76.89725714285714,63.933028571428565 Z M52.361485714285706,64.22765714285714 C55.81691428571429,64.22765714285714 58.65611428571428,61.388457142857135 58.65611428571428,57.906285714285715 C58.65611428571428,54.450857142857146 55.81691428571429,51.5848 52.361485714285706,51.5848 C48.879428571428576,51.5848 46.04011428571428,54.450857142857146 46.04011428571428,57.906285714285715 C46.04011428571428,61.388457142857135 48.879428571428576,64.22765714285714 52.361485714285706,64.22765714285714 Z"></path>
        </svg>
    </span>
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
        <InfiniteLoading spinner="circles" on:infinite={infiniteHandler} />
    {/if}
</Grid>

<style>
    .skeleton-image, .image {
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
