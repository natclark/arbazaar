<svelte:head>
    <title>Arbazaar</title>
</svelte:head>

<div class="top">
    <br>
    <div class="flex flex--center">
        <div>
            <h1><span class="bold">Arbazaar</span><br>Arbitrum's NFT Marketplace</h1>
            <p>Arbazaar is the Arbitrum community's go-to NFT marketplace.</p>
            <div class="flex flex--center">
                <a class="primary" href="/assets/" draggable="false" sveltekit:prefetch>Browse Items</a>
            </div>
        </div>
    </div>
</div>

<style>
    .top {
        h1 {
            text-shadow: 0 0 80px #888, 0 0 16px var(--fg-header);
            .bold {
                color: var(--ac-light);
                font-size: 64px;
            }
        }
        img {
            filter: drop-shadow(2px 4px 8px hsl(0deg 0% 0% / .4));
            max-width: 800px;
        }
    }
    .flex {
        column-gap: 24px;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        .flex__left {
            display: flex;
            flex: 1;
            flex-direction: column;
            text-align: center;
            p {
                font-size: 20px;
                line-height: 1.3em;
            }
        }
        .flex__right {
            display: flex;
            flex: 2;
            flex-direction: column;
            text-align: center;
            h2 {
                margin-bottom: 8px;
            }
            p {
                margin: 0 0 8px;
            }
        }
        &.flex--center {
            justify-content: center;
        }
    }
    .primary {
        border-radius: 8px;
        margin-top: 20px;
    }
    @media screen and (min-width: 768px) {
        .flex__left {
            h1, p {
                text-align: left !important;
            }
        }
        .tokens {
            border-collapse: separate !important;
            border-spacing: 0 1em !important;
        }
    }
</style>
