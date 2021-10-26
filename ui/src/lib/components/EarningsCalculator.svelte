<script>
    export let total; // The total amount of currently staked tokens

    let volume = 10;
    let stake = 100000;
</script>

<div class="flex">
    <div class="flex__card">
        <h3>Monthly Marketplace Volume</h3>
        <div class="value">
            <img class="eth" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1/logo.png" alt="ETH" loading="lazy">
            <input type="number" min={0} bind:value={volume}>
        </div>
    </div>
    <div class="flex__card">
        <h3>BUCK Stake</h3>
        <div class="value">
            <img class="buck" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0xAFD871f684F21Ab9D7137608C71808f83D75e6fc/logo.png" alt="BUCK" loading="lazy">
            <input type="number" min={0} max={100000000} bind:value={stake}>
        </div>
    </div>
    <div class="flex__card">
        <h3>Monthly Rewards</h3>
        <div class="value">
            <img class="eth" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1/logo.png" alt="ETH" loading="lazy">
            <p>{(stake / total) * volume * 0.02}</p>
        </div>
    </div>
</div>

<style>
    .flex {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        margin: 32px 0 60px;
        row-gap: 16px;
        text-align: center;
        .flex__card {
            background-color: var(--bg-soft);
            border-radius: 8px;
            padding: 4px 24px;
            width: 100%;
        }
    }
    .value {
        align-items: center;
        display: flex;
        justify-content: center;
        margin-bottom: 16px;
        input {
            background-color: var(--bg);
            border: 0;
            border-radius: 24px;
            box-shadow: rgba(0, 0, 0, .24) 0 1px 4px;
            color: var(--fg);
            font-family: var(--font) !important;
            font-size: 20px;
            max-width: 800px;
            opacity: .8;
            padding: 8px !important;
            transition: all .04s;
            width: 100%;
            will-change: box-shadow, opacity;
            &:hover, &:focus {
                box-shadow: rgba(0, 0, 0, .24) 0 3px 8px;
                opacity: 1;
            }
            &:focus {
                box-shadow: rgba(0, 0, 0, .16) 0 1px 4px, var(--ac) 0 0 0 2px;
                outline: none;
            }
        }
        img {
            border-radius: 50%;
            height: 32px;
            margin-right: 16px;
            width: 32px;
        }
    }
    @media screen and (min-width: 768px) {
        .flex {
            flex-direction: row;
            column-gap: 64px;
        }
    }
</style>
