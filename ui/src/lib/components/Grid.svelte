<script>
    export let small;
    export let fullbleed;
</script>

{#if !!small}
    <div class="grid grid--small">
        <slot />
    </div>
{:else if !!fullbleed}
    <div class="container">
        <div class="grid grid--fullbleed">
            <slot />
        </div>
    </div>
{:else}
    <div class="container">
        <div class="grid">
            <slot />
        </div>
    </div>
{/if}

<style>
    .container {
        display: flex;
        //height: 100%;
        justify-content: center;
        left: 5vw;
        position: absolute;
        right: 5vw;
        width: 90vw;
    }
    .grid {
        display: grid;
        gap: 14px;
        grid-template-columns: repeat(auto-fit, minmax(312px, min-content));
        max-width: 1160px;
        &.grid--small {
            gap: 20px;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            left: 0;
            margin-top: 0;
            max-width: 500px;
            position: static;
            right: 0;
            width: 100%;
        }
        &.grid--fullbleed {
            justify-content: space-between;
            max-width: 1290px;
            width: 100%;
        }
    }
</style>
