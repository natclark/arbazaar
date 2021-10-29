<script>
    import { onMount } from 'svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressArbazaar } from '../../../config';
    import Copy from '$lib/components/Copy.svelte';

    export let collection;
    export let tokenId;

    let offers = [];

    const removeOffer = async (offerKey, bidder) => {
        await defaultChainStore.setBrowserProvider();
        if ($selectedAccount !== null) {
            if ($selectedAccount !== bidder) {
                const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                contractArbazaar.methods.removeOffer(offerKey).send({
                    from: $selectedAccount,
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    Swal.fire(`Offer cancelled!`);
                });
            } else {
                Swal.fire(`This is not your offer!`);
            }
        } else {
            Swal.fire(`You must connect a wallet to do this!`);
        }
    };

    const acceptOffer = async (offerKey, price) => {
        await defaultChainStore.setBrowserProvider();
        if ($selectedAccount !== null) {
            if (balance >= price) {
                const contractArbazaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                contractArbazaar.methods.acceptOffer(collection, offerKey).send({
                    from: $selectedAccount,
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    Swal.fire(`Offer accepted!`);
                });
            } else {
                Swal.fire(`You don't currently own this item!`);
            }
        } else {
            Swal.fire(`You must connect a wallet to do this!`);
        }
    };

    onMount(async () => {
        if ($selectedAccount === null) {
            await defaultChainStore.setProvider(`https://arb1.arbitrum.io/rpc`);
        }
        const contractArbzaar = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
        offers = await contractArbzaar.methods.retrieveOffersByItem(collection, tokenId).call();
        offers = offers; // Svelte glitch
    });
</script>

<table class="history">
    <thead>
        <tr>
            <th>Bidder</th>
            <th>Price</th>
            <th>Block</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        {#each offers as offer}
            {#if offer.cancelled === false && offer.sold === false}
                <tr>
                    <td>
                        <a href="https://arbiscan.io/token/{offer.bidder}" rel="external noopener" target="_blank">
                            {offer.bidder.length > 5 ? `${offer.bidder.substring(0, 6)}...${offer.bidder.substring(offer.bidder.length - 6, offer.bidder.length)}` : offer.bidder}
                        </a>
                        <Copy text={offer.bidder} />
                    </td>
                    <td>
                        {$web3.utils.fromWei(offer.price, `ether`)}
                        <img class="eth" src="/img/ethereum-logo.png" alt="Ξ" loading="lazy">
                    </td>
                    <td>{offer.date}</td>
                    <td class="flex">
                        <a role="button" on:click={() => removeOffer(offer.offerKey, offer.bidder)}>Cancel</a>
                        <button class="primary" on:click={() => acceptOffer(parseInt(offer.offerKey), parseInt(offer.price))}>Accept Offer</button>
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

