<script>
    import { onMount } from 'svelte';
    let show = false;
    let ss;
    const close = () => {
        show = false;
        ss !== null && (ss.setItem(`arbucks::v0:banner`, `false`));
    };
    onMount(() => {
        if (typeof sessionStorage !== `undefined`) {
            ss = sessionStorage;
            try {
                if (ss.getItem(`arbucks::v0:banner`)) {
                    const banner = ss.getItem(`arbucks::v0:banner`);
                    if (banner == `true`) show = true;
                } else {
                    const banner = ss.setItem(`arbucks::v0:banner`, `true`);
                    show = true;
                }
            } catch (e) {}
        }
    });
</script>

{#if show}
    <div class="alert">
        <p>
            Arbazaar is very new and experimental! Please use at your own risk. We are not responsible for any damages.
        </p>
        <button on:click={close}>Close</button>
    </div>
{/if}

<style>
    .alert {
        align-items: center;
        background-color: var(--bg-soft) !important;
        border-radius: 8px;
        color: #fff;
        column-gap: 18px;
        display: flex;
        justify-content: center;
        left: 0;
        padding: 10px 20px;
        p {
            line-height: 1.3em;
            margin: 0;
        }
        button {
            align-items: center;
            background-color: var(--fg);
            border: 0;
            border-radius: 24px;
            cursor: pointer;
            color: var(--bg);
            display: flex;
            font-size: 18px;
            outline: none;
            padding: 4px 16px;
            transition: opacity .1s;
            will-change: opacity;
            &:hover {
                opacity: .8;
            }
        }
    }
</style>
