<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import Grid from '$lib/components/Grid.svelte';
    import NFT from '$lib/components/NFT.svelte';
    import InfiniteLoading from 'svelte-infinite-loading';
    import { COVALENT_KEY } from '../../../config';

    let nfts = [];

    const shuffle = (array) => array.sort(() => Math.random() - 0.5);

    const load = () => {
        return new Promise(async (resolve, reject) => {
            for (let i = 0; i < collections.length; i++) {
                const items = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${collections[i].address}/nft_token_ids/?key=${COVALENT_KEY()}`);
                const jsonItems = await items.json();
                if (jsonItems.error === false) {
                    nfts.push({
                        collection: collections[i].name,
                        id: Math.floor(Math.random() * jsonItems.data.pagination.total_count),
                        addressCollection: collections[i].address,
                    });
                    nfts = nfts; // Svelte glitch
                    i === collections.length - 1 && (resolve(true));
                } else {
                    // todo handle error
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
        load();
    });
</script>

<svelte:head>
    <title>Assets - Arbazaar</title>
</svelte:head>

<h1>Arbazaar</h1>
<p class="subtitle">Arbitrum's NFT marketplace</p>

<Grid fullbleed="true">
    {#each nfts as nft}
        <NFT
            collection={nft.collection}
            id={nft.id}
            addressCollection={nft.addressCollection}
        />
    {/each}
    <InfiniteLoading spinner="circles" on:infinite={infiniteHandler} />
</Grid>

<style>
    .cell {
        align-items: center;
        background-color: #333;
        color: #fff;
        display: flex;
        height: 60px;
        justify-content: center;
    }
</style>
