<script>
    import { onMount } from 'svelte';
    import collections from '$lib/constants/collections';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import ERC721 from '$lib/abi/ERC721';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import wallet from '$lib/stores/wallet';
    import Copy from '$lib/components/Copy.svelte';
    import Grid from '$lib/components/Grid.svelte';
    import Modal from 'svelte-simple-modal';
    import ListItemButton from '$lib/components/ListItemButton.svelte';
    import MakeOfferButton from '$lib/components/MakeOfferButton.svelte';
    import Listings from '$lib/components/Listings.svelte';
    import Offers from '$lib/components/Offers.svelte';
    import PriceHistory from '$lib/components/PriceHistory.svelte';
    import TradingHistory from '$lib/components/TradingHistory.svelte';
    import MoreItems from '$lib/components/MoreItems.svelte';

    /* A more reliable and decentralized solution for fetching data is a high-priority upcoming feature. */
    const COVALENT_KEY = `ckey_f02916bdd2b04038bc0808fb3bc`;

    let addressCollection = ``;
    let id = 0;
    let image = ``;
    let collection = ``;
    let updatedAt = ``;
    let name = ``;
    let description = ``;
    let supply = 0;
    let creator = ``;
    let owner = ``;
    let addressOwner = ``;
    let properties = [];

    const effect = `wave`;

    const load = async () => {
        $selectedAccount === null && (await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`));
        const contract = await new $web3.eth.Contract(ERC721.abi, addressCollection);
        contract.methods.name().call()
            .then((result) => collection = result)
            .catch((e) => {});
        contract.methods.totalSupply().call()
            .then((result) => supply = result)
            .catch((e) => {});
        const items = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${addressCollection}/nft_token_ids/?key=${COVALENT_KEY}`);
        const jsonItems = await items.json();
        if (jsonItems.error === false) {
            updatedAt = jsonItems.data.updated_at;
        } else {
            console.log(`ERROR`);
        }
        const metadata = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${addressCollection}/nft_metadata/${id}/?key=${COVALENT_KEY}`);
        const jsonMetadata = await metadata.json();
        if (jsonMetadata.error === false) {
            try {
                const data = jsonMetadata.data.items[0].nft_data[0];
                image = data.external_data.image;
                if (image.includes(`http`) === false) {
                    if (!!image.endsWith(`.mp4`)) {
                        image = `https://gateway.ipfs.io/ipfs/${image}`;
                    } else {
                        image = `https://cloudflare-ipfs.com/ipfs/${image}`;
                    }
                }
                name = data.external_data.name;
                description = data.external_data.description;
                creator = data.original_owner;
                owner = data.owner;
                addressOwner = data.owner_address;
                if (data.external_data.attributes !== null) {
                    properties = data.external_data.attributes;
                }
            } catch (e) {
                console.log(`ERROR`);
            }
        } else {
            console.log(`ERROR`);
        }
    };

    onMount(() => {
        try {
            const matches = $page.path.match(new RegExp(`/assets/(.*)/(.*)/`));
            if (matches.length === 3) {
                addressCollection = matches[1];
                id = matches[2];
                load();
            } else {
                //goto(`/`);
            }
        } catch (e) {
            //goto(`/`);
        }
        /*
        if (collections.includes(addressCollection) === false) {
            //goto(`/`);
        }
        */
    });
</script>

<svelte:head>
    <title>{name} NFT Collection - Arbazaar</title>
</svelte:head>

<div class="flex flex--main">
    <section class="left">
        {#if image === ``}
            <span class="skeleton-image skeleton-effect-wave">
                <svg width="500" height="500" viewBox="0 0 500 500" preserveAspectRatio="none" style="border-radius: 16px">
                    <polygon fillrule="evenodd" points="0 0 500 0 500 500 0 500"></polygon>
                    <path d="M159,346 L341,346 C362,346 373,335 373,314 L373,186 C373,165 362,154 341,154 L159,154 C138,154 127,164 127,186 L127,314 C127,336 138,346 159,346 Z M300,250 C296,246 290,243 285,243 C279,243 274,245 269,250 L222,292 L202,274 C198,270 193,268 188,268 C184,268 179,270 175,274 L143,302 L143,187 C143,176 149,171 160,171 L340,171 C351,171 357,176 357,187 L357,302 L300,250 Z M205,251 C218,251 229,240 229,226 C229,213 218,202 205,202 C191,202 180,213 180,226 C180,240 191,251 205,251 Z"></path>
                </svg>
            </span>
        {:else}
            <img class="image" src={image} alt="{name} Logo" loading="lazy">
        {/if}
        <h2>Description</h2>
        <p class="creators">
            Created by
            <a href="https://arbiscan.io/address/{creator}" rel="external noopener" target="_blank">
                {creator.length > 5 ? `${creator.substring(0, 6)}...${creator.substring(creator.length - 6, creator.length)}` : creator}
            </a>
        </p>
        <p class="description">{description}</p>
        <h2>Properties</h2>
        <Grid small="true">
            {#each properties as property}
                <a class="property" href="/collection/{addressCollection}/?{property.trait_type}={property.value}">
                    <div class="property__container">
                        <p>{property.trait_type}</p>
                        <p>{property.value}</p>
                    </div>
                </a>
            {/each}
        </Grid>
        <h2>Details</h2>
        <div class="details">
            <div class="flex">
                <p>Last Updated</p>
                <p>
                    <time datetime={updatedAt}>
                        {new Date(updatedAt).toLocaleDateString(undefined, { day: `numeric`, hour: `numeric`, month: `long`, year: `numeric`, })}
                    </time>
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Collection Address</p>
                <p>
                    <a href="https://arbiscan.io/token/{addressCollection}" rel="external noopener" target="_blank">
                        {addressCollection.length > 5 ? `${addressCollection.substring(0, 6)}...${addressCollection.substring(addressCollection.length - 6, addressCollection.length)}` : addressCollection}
                    </a>
                    <Copy text={addressCollection} />
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Token ID</p>
                <p>
                    <a href="https://arbiscan.io/token/{addressCollection}?a={id}" rel="external noopener" target="_blank">
                        {id}
                    </a>
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Token Standard</p>
                <p>
                    ERC-721
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Asset Platform</p>
                <p>
                    Ethereum
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Blockchain</p>
                <p>
                    Arbitrum
                </p>
            </div>
            <div class="flex flex--mobile">
                <p>Chain ID</p>
                <p>
                    42161
                </p>
            </div>
        </div>
    </section>
    <section class="right">
        <p class="collection">
            <a href="/collection/{addressCollection}/">{collection}</a>
        </p>
        <h1 class="name">{name}</h1>
        <p class="owner">
            Owned by
            <a href="https://arbiscan.io/address/{addressOwner}" rel="external noopener" target="_blank">
                {owner.length > 5 ? `${owner.substring(0, 6)}...${owner.substring(owner.length - 6, owner.length)}` : owner}
            </a>
            <Copy text={addressOwner} />
        </p>
        <h2>Listings</h2>
        <Modal>
            <ListItemButton
                collection={addressCollection}
                tokenId={id}
            />
        </Modal>
        <Listings
            collection={addressCollection}
            tokenId={id}
        />
        <h2>Offers</h2>
        <Modal>
            <MakeOfferButton
                collection={addressCollection}
                tokenId={id}
            />
        </Modal>
        <Offers
            collection={addressCollection}
            tokenId={id}
        />
        <!--
        <h2>Price History</h2>
        <PriceHistory />
        -->
    </section>
</div>

<!--
<h2>Trading History</h2>
<TradingHistory />
-->

<h2>More Items From {collection}</h2>
<MoreItems
    {collection}
    {addressCollection}
/>

<style>
    .flex {
        align-items: flex-start;
        column-gap: 24px;
        display: flex;
        justify-content: space-between;
        margin-top: 30px;
        section {
            width: 100%;
            &.left {
                max-width: 500px;
            }
            &.right {
                max-width: 624px;
            }
        }
        &.flex--main {
            display: block;
        }
    }
    h1, h2, h3, h4, h5, h6, p {
        text-align: left;
    }
    h2 {
        color: #eee;
    }
    .image {
        border-radius: 16px;
        height: 100%;
        max-height: 600px;
        max-width: 600px;
        object-fit: cover;
        width: 100%;
    }
    .description {
        line-height: 1.5;
    }
    .property {
        color: var(--fg);
        max-width: 150px;
        opacity: 1;
        text-decoration: none;
        .property__container {
            background-color: var(--bg-soft);
            border: 1px solid var(--ac);
            border-radius: 16px;
            max-width: 150px;
            transition: background-color .08s;
            width: 100%;
            will-change: background-color;
            p {
                text-align: center;
                &:first-child {
                    font-size: 12px;
                    text-transform: uppercase;
                }
                &:last-child {
                    font-weight: 700;
                }
            }
        }
        &:hover {
            .property__container {
                background-color: var(--ac-light);
            }
        }
    }
    .details {
        background-color: var(--bg-soft);
        border-radius: 8px;
        padding: 4px 24px;
        .flex p:first-child {
            color: #ccc;
        }
    }
    .name {
        font-size: 40px;
        font-weight: 600;
        margin-top: 0;
    }
    @media screen and (min-width: 768px) {
        .flex.flex--main {
            display: flex;
        }
    }
</style>
