<script>
    import { onMount } from 'svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressArbazaar } from '../../../config';
    import Copy from '$lib/components/Copy.svelte';

    export let collection;
    export let tokenId;

    let listings = [];

    const removeListing = async (listingKey, seller) => {
        await defaultChainStore.setBrowserProvider();
        if (!!$connected) {
            if ($selectedAccount !== seller) {
                const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                contractArbazaar.methods.removeListing(listingKey).send({
                    from: $selectedAccount
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    Swal.fire(`Listing cancelled!`);
                });
            } else {
                Swal.fire(`This is not your listing!`);
            }
        } else {
            Swal.fire(`You must connect a wallet to do this!`);
        }
    };

    const purchaseListing = async (listingKey, price) => {
        await defaultChainStore.setBrowserProvider();
        if (!!$connected) {
            if ($web3.utils.toWei(await $web3.eth.getBalance($selectedAccount), `ether`) >= price) {
                const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                contractArbazaar.methods.purchaseListing(collection, listingKey).send({
                    from: $selectedAccount,
                    value: price + ((price / 1e18) * (20 * 1e15)) + ((price / 1e18) * (5 * 1e15)),
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    Swal.fire(`Listing purchased!`);
                });
            } else {
                Swal.fire(`You currently don't own enough ETH to buy this!`);
            }
        } else {
            Swal.fire(`You must connect a wallet to do this!`);
        }
    };

    onMount(async () => {
        await defaultChainStore.setBrowserProvider();
        if (!!$connected) {
            const contractArbzaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
            listings = await contractArbzaar.methods.retrieveListingsByItem(collection, tokenId).call();
        }
    });
</script>

<table class="history">
    <thead>
        <tr>
            <th>Seller</th>
            <th>Price</th>
            <th>Block</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        {#each listings as listing}
            {#if listing.cancelled === false && listing.sold === false}
                <tr>
                    <td>
                        <a href="https://arbiscan.io/token/{listing.seller}" rel="external noopener" target="_blank">
                            {listing.seller.length > 5 ? `${listing.seller.substring(0, 6)}...${listing.seller.substring(listing.seller.length - 6, listing.seller.length)}` : listing.seller}
                        </a>
                        <Copy text={listing.seller} />
                    </td>
                    <td>
                        {$web3.utils.fromWei(listing.price, `ether`)}
                        <img class="eth" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy">
                    </td>
                    <td>{listing.date}</td>
                    <td class="flex">
                        <a role="button" on:click={() => removeListing(listing.listingKey, listing.seller)}>Cancel</a>
                        <button class="primary" on:click={() => purchaseListing(parseInt(listing.listingKey), parseInt(listing.price))}>Buy Now</button>
                    </td>
                </tr>
            {/if}
        {/each}
    </tbody>
</table>

<style>
    .history {
        background-color: var(--bg-soft);
        border-radius: 8px;
        margin-top: 24px;
        min-height: 50px;
        padding-top: 12px;
        width: 100%;
        tr {
            th:first-child, td:first-child {
                text-align: left;
            }
            th, td {
                padding: 8px;
            }
        }
        .primary {
            font-size: 16px;
            height: 30px;
        }
    }
    .eth {
        left: 4px;
        position: relative;
        top: 2px;
    }
    .flex {
        align-items: center;
        column-gap: 8px;
        display: flex;
        justify-content: center;
        a {
            color: #ddd;
            cursor: pointer;
        }
    }
</style>
