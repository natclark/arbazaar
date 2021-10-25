<script>
    export let small;
    export let fullbleed;
</script>

<div class="grid{!!small ? ` grid--small` : ``}{!!fullbleed ? ` grid--fullbleed` : ``}">
    <slot />
</div>

<style>
    .grid {
        display: grid;
        gap: 20px;
        grid-template-columns: repeat(auto-fit, minmax(312px, 1fr));
        left: 5vw;
        position: absolute;
        right: 5vw;
        width: 90vw;
        &.grid--small {
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            left: 0;
            position: static;
            right: 0;
            width: 100%;
        }
        &.grid--fullbleed {
            left: 50%;
            justify-content: space-around;
            margin: auto -45vw;
            position: relative;
            right: 50%;
        }
    }
</style>
