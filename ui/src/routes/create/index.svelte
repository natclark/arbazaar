<script>
    import { Web3Storage } from 'web3.storage';
    import { addressArbazaar } from '../../../config';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import TemplateNFT from '$lib/abi/TemplateNFT.json';
    import Arbazaar from '$lib/abi/Arbazaar.json';

    // * Yes, this is bad practice - but it is temporary. If someone abuses this key before I switch to something else, I'll add a new one ASAP.
    const token = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGI0MEIzZGU3Y0Y2Mjk3MTZBNDM2NGQ2NWY2NTJBMzNCOTU5N2E0QzEiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2MzQ5NDQzMTQ2NDcsIm5hbWUiOiJBcmJpdHJ1bSJ9.OsMJ0VOa76bMZnsQ5EYjZevfUly2VXrWbbZHbsnPcwM`;

    let screen = `choose`;

    let files = null;
    let collection = null;
    let symbol = null;
    let name = null;
    let description = null;
    let price = null;
    let currency = null;
    let checked = false;

    let stage = 0;

    const addListing = async (urlMetadata) => {
        const contractTemplateNFT = await new $web3.eth.Contract(TemplateNFT.abi);

        stage = 3;

        contractTemplateNFT.deploy({
            data: TemplateNFT.bytecode,
            arguments: [addressArbazaar, collection, symbol],
        }).send({
            from: $selectedAccount,
            gasPrice: $web3.utils.toWei(`1.2`, `Gwei`),
        }).once(`error`, () => {
            // TODO
        }).once(`transactionHash`, () => {
            // TODO
            stage = 4;
        }).once(`receipt`, async (receipt) => {
            contractTemplateNFT.options.address = receipt.contractAddress;

            contractTemplateNFT.methods.createToken(urlMetadata).send({
                from: $selectedAccount,
                gasPrice: $web3.utils.toWei(`1.2`, `Gwei`),
            }).once(`error`, () => {
                // TODO
            }).once(`transactionHash`, () => {
                // TODO
                stage = 5;
            }).once(`receipt`, async (receipt) => {
                if (!!checked && price !== null) {
                    stage = 6;
                    const tokenId = parseInt(receipt.events.Transfer.returnValues.tokenId);
                    const wei = $web3.utils.toWei(price, `ether`);
        
                    const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
        
                    contractArbazaar.methods.addListing(contractTemplateNFT.options.address, tokenId, wei).send({
                        from: $selectedAccount,
                        gasPrice: $web3.utils.toWei(`1.2`, `Gwei`),
                    }).once(`error`, (error) => {
                        // TODO
                    }).once(`transactionHash`, () => {
                        // TODO
                        stage = 7;
                    }).once(`receipt`, async (receipt) => {
                        // TODO
                        stage = 0;
                    });
                } else {
                    stage = 0;
                }
            });
        });
    };

    const create = async () => {
        if (files === null || collection === null || symbol === null || name === null || description === null) return;
        if (!!checked && price === null) return;
        if ($selectedAccount !== null) {
            if (stage === 0) {
                stage = 1;
                try {
                    const client = new Web3Storage({ token, });
                    const cidMedia = await client.put(files, files[0].name);
                    try {
                        const data = {
                            name,
                            description,
                            image: `https://cloudflare-ipfs.com/ipfs/${cidMedia}/${files[0].name}`,
                        };
                        const blob = new Blob([JSON.stringify(data)], {
                            type: `application/json`,
                        });
                        const cidMetadata = await client.put([new File([blob], `metadata.json`)]);
                        const urlMetadata = `https://cloudflare-ipfs.com/ipfs/${cidMetadata}/metadata.json`;
                        stage = 2;
                        addListing(urlMetadata);
                    } catch (error) {
                        Swal.fire(`Error uploading metadata: ${error}`);
                    }
                } catch (error) {
                    Swal.fire(`Error uploading media: ${error}`);
                }
            }
        } else {
            if (typeof window.ethereum !== `undefined`) {
                defaultChainStore.setBrowserProvider();
            } else {
                Swal.fire(`You must have a web3-enabled Ethereum wallet like Metamask to do this!`);
            }
        }
    };

    const connectWallet = () => {};
</script>

<svelte:head>
    <title>Create an NFT on Arbitrum - Arbazaar</title>
</svelte:head>

<h1>Create an NFT on Arbitrum</h1>
<p class="subtitle">This portal offers a quick and simple way to start tokenizing, sharing, and selling your creations as digital assets on Arbitrum.<br><strong>Further improvements are on the way.</strong></p>

{#if screen === `choose`}
    <div class="flex flex--row flex--center">
        <div class="flex flex--center">
            <button class="primary primary--rect" on:click={() => screen = `mint`}>
                Mint 1 of 1
            </button>
            <button class="primary primary--rect" on:click={()=> screen = `create`}>
                Create New Collection
            </button>
            <button class="primary primary--rect" on:click={() => screen = `add`}>
                Add To Existing Collection
            </button>
        </div>
    </div>
{/if}

{#if screen === `mint`}
    <p>
        <a class="back" role="button" on:click={() => screen = `choose`}>&#8592; Go Back</a>
    </p>
    <form on:submit|preventDefault={create}>
        <div class="field">
            <label for="media" class="field__label">Upload Media</label>
            <input id="media" class="field__input" type="file" bind:files required aria-required="true">
        </div>

        <div class="field">
            <label for="collection" class="field__label">Collection Name</label>
            <input id="collection" class="field__input" type="text" bind:value={collection} required aria-required="true">
        </div>

        <div class="field">
            <label for="symbol" class="field__label">Collection Symbol</label>
            <input id="symbol" class="field__input" type="text" bind:value={symbol} required aria-required="true">
        </div>

        <div class="field">
            <label for="name" class="field__label">Item Name</label>
            <input id="name" class="field__input" type="text" bind:value={name} required aria-required="true">
        </div>

        <div class="field">
            <label for="description" class="field__label">Description</label>
            <input id="description" class="field__input" type="text" bind:value={description} required aria-required="true">
        </div>

        <div class="field">
            <label class="field__label">
                <input type=checkbox bind:checked>
                List Item After Minting
            </label>
        </div>

        {#if !!checked}
            <div class="field">
                <label for="price" class="field__label">Price (ETH)</label>
                <input id="price" class="field__input" type="text" bind:value={price} required aria-required="true">
            </div>
        {/if}

        <button class="primary" type="submit">
            {#if $selectedAccount !== null}
                {#if stage === 1}
                    Creating Metadata...
                {:else if stage === 2}
                    Deploy Contract
                {:else if stage === 3}
                    Deploying Contract...
                {:else if stage === 4}
                    Mint Item
                {:else if stage === 5}
                    Minting Item...
                {:else if stage === 6}
                    List Item
                {:else if stage === 7}
                    Listing Item...
                {:else}
                    Create
                {/if}
            {:else}
                Connect Wallet
            {/if}
        </button>
    </form>
    <p>
        <br>
        <strong>WARNING: This process will improve in the future, but be prepared to pay gas for 2-3 transactions, back-to-back. We do not charge additional minting fees.</strong>
    </p>
{:else if screen === `create`}
    <p>
        <a class="back" role="button" on:click={()=> screen = `choose`}>&#8592; Go Back</a>
    </p>
    <h2 class="text-center">My Collections</h2>
    <div class="flex flex--row flex--center">
        <div class="flex flex--center">
            <button class="primary primary--rect" on:click={connectWallet}>
                Connect Wallet
            </button>
        </div>
    </div>
{:else if screen === `add`}
    <p>
        <a class="back" role="button" on:click={()=> screen = `choose`}>&#8592; Go Back</a>
    </p>
    <h2 class="text-center">My Collections</h2>
    <div class="flex flex--row flex--center">
        <div class="flex flex--center">
            <button class="primary primary--rect" on:click={connectWallet}>
                Connect Wallet
            </button>
        </div>
    </div>
{/if}


<style>
    h2:not(.text-center), h3, h4, h5, h6, p:not(.subtitle) {
        text-align: left;
    }
    .flex {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        row-gap: 24px;
        &.flex--row {
            column-gap: 24px;
            flex-direction: row;
        }
        &.flex--center {
            justify-content: center;
        }
    }
    .back {
        cursor: pointer;
        font-size: 20px;
        margin: 0 0 12px 8px;
    }
    .field {
        display: flex;
        flex-direction: column;
        margin-bottom: 36px;
        .field__label {
            margin: 0 0 12px 8px;
            text-align: left;
        }
        .field__input {
            background-color: var(--bg-soft);
            border: 0;
            border-radius: 16px;
            color: var(--color);
            font-size: 18px;
            margin: 0 0 0 0;
            max-width: 300px;
            padding: 12px;
            width: 100%;
        }
    }
    .primary--rect {
        border-radius: 8px;
        font-size: 18px;
        margin: 0 auto;
        width: 300px;
    }
    @media screen and (min-width: 768px) {
        .field .field__input {
            max-width: 600px;
        }
    }
</style>
