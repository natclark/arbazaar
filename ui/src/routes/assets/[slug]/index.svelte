<script>
    import { onMount } from 'svelte';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';

    onMount(() => {
        try {
            address = $page.path.replace(`/assets/`, ``);
            address = address.replace(`/`, ``);
            goto(`/collection/${address}/`);
        } catch (e) {
            //goto(`/`);
        }
        if (collections.includes(address) === false) {
            //goto(`/`);
        }
    });
</script>
