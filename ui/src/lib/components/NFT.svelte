<script>
    import { onMount } from 'svelte';
    import { SkeletonText, SkeletonBlock, SkeletonImage, SkeletonAvatar } from 'skeleton-elements/svelte';

    export let collection;
    export let id;
    export let addressCollection;

    const effect = `wave`;

    let name = ``;
    let image = ``;
    let imageBlob = new Image();
    let imageLoaded = false;

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
                        image = `https://cloudflare-ipfs.com/ipfs/${image}`;
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
            <SkeletonImage {effect} height={312} width={312} borderRadius="16px 16px 0 0" />
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
                <SkeletonText {effect} tag="p" class="nft__name">
                    Item Name
                </SkeletonText>
            {:else}
                <p class="nft__name">{name}</p>
            {/if}
        </div>
        <div>
            <!--
                TODO
            <p class="nft__price"><img class="eth eth--small" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy"> 0.1</p>
            <p class="nft__last"><img class="eth eth--small" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy"> 0.05</p>
            -->
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
                        font-weight: 700;
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
