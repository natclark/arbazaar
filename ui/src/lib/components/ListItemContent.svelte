<script>
    import { onMount } from 'svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressArbazaar } from '../../../config';

    export let collection;
    export let tokenId;

    let price = 0;

    let listing = false;

    const listItem = async () => {
        if ($selectedAccount !== null) {
            try {
                price = parseFloat(price);
            } catch (e) {
                Swal.fire(`You must enter a number!`);
            }
            if (price >= 0.001) {
                const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                const wei = $web3.utils.toWei(price.toString(), `ether`);
                contractArbazaar.methods.addListing(collection, tokenId, wei).send({
                    from: $selectedAccount,
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    // TODO
                });
            } else {
                Swal.fire(`The price must be greater than 0.001 ETH!`);
            }
        } else {
            Swal.fire(`Please connect your wallet first!`);
        }
    };

    onMount(async () => {
        await defaultChainStore.setBrowserProvider();
    });
</script>

<h2>List Item</h2>
<input type="text" bind:value={price}>
<div class="flex">
    <button class="primary" on:click={listItem}>
        List
    </button>
</div>

<style>
    .value {
        align-items: center;
        display: flex;
        justify-content: center;
        .value__number {
            font-size: 48px;
            font-weight: 500;
        }
        img {
            border-radius: 50%;
            height: 32px;
            margin-right: 16px;
            width: 32px;
        }
    }
    input {
        background-color: var(--bg);
        border: 0;
        border-radius: 24px;
        box-shadow: rgba(0, 0, 0, .24) 0 1px 4px;
        color: var(--fg);
        font-family: var(--font) !important;
        font-size: 20px;
        margin-bottom: 16px;
        max-width: 800px;
        opacity: .8;
        padding: 8px !important;
        transition: all .04s;
        width: 100%;
        will-change: box-shadow, opacity;
        &:hover, &:focus {
            box-shadow: rgba(0, 0, 0, .24) 0 3px 8px;
            opacity: 1;
        }
        &:focus {
            box-shadow: rgba(0, 0, 0, .16) 0 1px 4px, var(--ac) 0 0 0 2px;
            outline: none;
        }
    }
    .flex {
        align-items: center;
        display: flex;
        flex-direction: column;
        row-gap: 16px;
        justify-content: center;
    }
</style>
