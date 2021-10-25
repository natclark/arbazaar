<script>
    import { onMount } from 'svelte';
    import Grid from '$lib/components/Grid.svelte';
    import NFT from '$lib/components/NFT.svelte';
    import InfiniteLoading from 'svelte-infinite-loading';

    export let collection;
    export let addressCollection;

    let nfts = [];

    const shuffle = (array) => array.sort(() => Math.random() - 0.5);

    /* A more reliable and decentralized solution for fetching data is a high-priority upcoming feature. */
    const COVALENT_KEY = `ckey_f02916bdd2b04038bc0808fb3bc`;

    const load = () => {
        return new Promise(async (resolve, reject) => {
            for (let i = 0; i < 10; i++) {
                const items = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${addressCollection}/nft_token_ids/?key=${COVALENT_KEY}`);
                const jsonItems = await items.json();
                if (jsonItems.error === false) {
                    if (jsonItems.data.pagination.total_count > 1) {
                        nfts.push({
                            collection,
                            id: Math.floor(Math.random() * jsonItems.data.pagination.total_count),
                            addressCollection,
                        });
                        nfts = nfts; // Svelte glitch
                        i === 9 && (resolve(true));
                    } else {
                        console.log(`ERROR`);
                        resolve(false);
                    }
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

<Grid>
    {#each nfts as nft}
        <NFT
            collection={nft.collection}
            id={nft.id}
            addressCollection={nft.addressCollection}
        />
    {/each}
    <!--
    <InfiniteLoading on:infinite={infiniteHandler} />
    -->
</Grid>
