<script>
    import { onMount } from 'svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainId, chainData } from 'svelte-web3';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressTemplateNFT, addressArbazaar } from '../../../config';

    export let collection;
    export let id;
    export let addressCollection;

    const effect = `wave`;

    let name = ``;
    let image = ``;
    let imageBlob = new Image();
    let imageLoaded = false;

    let listings = [];
    let price = null;

    onMount(async () => {
        /* A more reliable and decentralized solution for fetching data is a high-priority upcoming feature. */
        const COVALENT_KEY = `ckey_f02916bdd2b04038bc0808fb3bc`;
        const metadata = await fetch(`https://api.covalenthq.com/v1/42161/tokens/${addressCollection}/nft_metadata/${id}/?key=${COVALENT_KEY}`);
        const jsonMetadata = await metadata.json();
        if (jsonMetadata.error === false) {
            try {
                const data = jsonMetadata.data.items[0].nft_data[0];
                name = data.external_data.name;
                image = data.external_data.image;
                if (typeof image === `string`) {
                    if (image.includes(`http`) === false) {
                        if (!!image.endsWith(`.mp4`)) {
                            image = `https://gateway.ipfs.io/ipfs/${image}`;
                        } else {
                            image = `https://cloudflare-ipfs.com/ipfs/${image}`;
                        }
                    }
                } else {
                    // TODO
                    const blb = new Blob([image], { type: `text/plain`, });
                    const reader = new FileReader();
                    reader.addEventListener(`loadend`, (e) => {
                        const text = e.srcElement.result;
                        console.log(text);
                    });
                    image = reader.readAsText(blb);
                }
                imageBlob.onload = () => {
                    imageLoaded = true;
                };
                imageBlob.src = image;

                $selectedAccount !== null && (await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`));
                const marketContract = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                const dataListings = await marketContract.methods.retrieveListingsByItem(addressCollection, id).call();
                console.log(dataListings);
                listings = await Promise.all(dataListings.map(async (e) => {
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

                listings.length > 0 && (price = listings[listings.length - 1].price);
            } catch (e) {
                // TODO
                console.log(jsonMetadata);
            }
        } else {
            console.log(`ERROR`);
        }
    });
</script>

<a class="nft" href="/assets/{addressCollection}/{id}/">
    <div class="nft__thumbnail">
        {#if imageLoaded === false}
            <span class="skeleton-image skeleton-effect-wave">
                <svg width="312" height="312" viewBox="0 0 312 312" preserveAspectRatio="none" style="border-radius: 16px 16px 0 0">
                    <polygon fillrule="evenodd" points="0 0 312 0 312 312 0 312"></polygon>
                    <path d="M99,216 L213,216 C226,216 233,209 233,196 L233,116 C233,103 226,96 213,96 L99,96 C86,96 79,103 79,116 L79,196 C79,209 86,216 99,216 Z M187,156 C184,153 181,152 178,152 C174,152 171,153 168,156 L138,182 L126,171 C123,169 121,167 117,167 C115,167 112,169 109,171 L90,189 L90,117 C90,110 93,106 100,106 L212,106 C219,106 222,110 222,117 L222,189 L187,156 Z M128,157 C136,157 143,150 143,141 C143,133 136,126 128,126 C119,126 112,133 112,141 C112,150 119,157 128,157 Z"></path>
                </svg>
            </span>
        {:else}
            <img src={image} alt={name} loading="lazy">
        {/if}
    </div>
    <div class="nft__details">
        <div>
            <p class="nft__collection">
                <a href="/collection/{addressCollection}/">
                    {collection}
                </a>
            </p>
            {#if name === ``}
            <p class="skeleton-text skeleton-effect-wave nft__name">Item Name</p>
            {:else}
                <p class="nft__name">{name}</p>
            {/if}
        </div>
        <div>
            {#if price !== null}
                <p class="nft__price"><img class="eth eth--small" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy"> {price}</p>
            {/if}
            <!--<p class="nft__last"><img class="eth eth--small" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy"> 0.05</p>-->
        </div>
    </div>
</a>

<style>
    .nft {
        background-color: var(--bg-soft);
        border-radius: 16px 16px;
        box-shadow: rgba(0, 0, 0, .16) 0 1px 4px;
        color: #fff;
        display: block;
        max-width: 312px;
        min-width: 256px;
        opacity: 1;
        text-decoration: none;
        transition: transform .1s ease;
        width: 100%;
        will-change: transform;
        .nft__thumbnail {
            background-color: #ddd;
            border-radius: 20px 20px 0 0;
            height: 312px;
            margin: 0;
            img {
                background-color: #ddd;
                border-radius: 16px 16px 0 0;
                height: 312px;
                max-width: 312px;
                object-fit: cover;
                width: 100%;
            }
        }
        .nft__details {
            display: flex;
            justify-content: space-between;
            height: 120px;
            padding: 12px;
            div {
                text-align: left;
                p {
                    margin-top: 0;
                    margin-bottom: 4px;
                    &.nft__collection a {
                        color: #ddd !important;
                        font-size: 12px;
                        opacity: 1;
                        text-decoration: none;
                        &:hover {
                            color: #fff !important;
                        }
                    }
                    &.nft__name {
                        font-size: 12px;
                        font-weight: 700;
                    }
                    &.nft__price, &.nft__last {
                        font-size: 13px;
                        font-weight: 500;
                    }
                    &.nft__price {
                        align-items: center;
                        column-gap: 6px;
                        display: flex;
                        img {
                            margin-bottom: 1px;
                        }
                    }
                }
                &:last-child {
                    text-align: right;
                }
            }
        }
        &:hover {
            transform: translateY(-2px);
        }
    }
</style>
