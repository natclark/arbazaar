<script>
    import { getContext } from 'svelte';
    import ListItemContent from './ListItemContent.svelte';

    export let collection;
    export let tokenId;

    const { open, } = getContext(`simple-modal`);

    const listItem = () => open(ListItemContent, {
        collection,
        tokenId,
    });
</script>

<button class="primary" on:click={listItem}>
    List Item
</button>
