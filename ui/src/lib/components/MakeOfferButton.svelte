<script>
    import { getContext } from 'svelte';
    import MakeOfferContent from './MakeOfferContent.svelte';

    export let collection;
    export let tokenId;

    const { open, } = getContext(`simple-modal`);

    const listItem = () => open(MakeOfferContent, {
        collection,
        tokenId,
    });
</script>

<button class="primary" on:click={listItem}>
    Make Offer
</button>
