<script>
    import { getContext } from 'svelte';
    import ManageStakeContent from './ManageStakeContent.svelte';

    const { open, } = getContext(`simple-modal`);

    const manageStake = () => open(ManageStakeContent);
</script>

<button class="primary" on:click={manageStake}>
    Manage Stake
</button>
