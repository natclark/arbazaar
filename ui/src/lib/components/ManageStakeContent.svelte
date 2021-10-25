<script>
    import { onMount } from 'svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import MockBUCK from '$lib/abi/MockBUCK.json';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressMockBUCK, addressArbazaar } from '../../../config';

    let balance = 0;
    let allowance = 0;
    let stake = 0;

    let amountAdd = 0;
    let amountRemove = 0;

    let approving = false;

    const approveTokens = async () => {
        if (approving === false) {
            approving = true;
            const contractToken = await new $web3.eth.Contract(MockBUCK.abi, addressMockBUCK);
            contractToken.methods.approve(addressArbazaar, `115792089237316195423570985008687907853269984665640564039457584007913129639935`).send({
                from: $selectedAccount,
            }).once(`error`, () => {
                // TODO
                approving = false;
            }).once(`transactionHash`, () => {
                // TODO
            }).once(`receipt`, async (receipt) => {
                const dataAllowance = await contractToken.methods.allowance($selectedAccount, addressArbazaar).call();
                allowance = $web3.utils.fromWei(dataAllowance, `ether`);
                approving = false;
            });
        }
    };

    const addStake = async () => {
        try {
            amountAdd = parseFloat(amountAdd);
        } catch (e) {
            Swal.fire(`You must enter a number!`);
        }
        if (balance >= amountAdd) {
            if (amountAdd >= 1000) {
                const contractFarm = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                const wei = $web3.utils.toWei(amountAdd, `ether`);
                contractFarm.methods.addStake(wei).send({
                    from: $selectedAccount,
                }).once(`error`, () => {
                    // TODO
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    const contractToken = await new $web3.eth.Contract(MockBUCK.abi, addressMockBUCK);
                    const dataBalance = await contractToken.methods.balanceOf($selectedAccount).call();
                    balance = $web3.utils.fromWei(dataBalance, `ether`);

                    const dataStake = await contractFarm.methods.getStakeByUser($selectedAccount).call();
                    stake = $web3.utils.fromWei(dataStake, `ether`);
                });
            } else {
                Swal.fire(`You must stake at least 1,000 BUCK at a time!`);
            }
        } else {
            Swal.fire(`You don't own enough BUCK to do this!`);
        }
    };

    const removeStake = async () => {
        try {
            amountRemove = amountRemove.toNumber();
        } catch (e) {
            Swal.fire(`You must enter a number!`);
        }
        if (stake >= amountRemove) {
            const contractFarm = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
            const wei = $web3.utils.toWei(amountRemove, `ether`);
            contractFarm.methods.removeStake(wei).send({
                from: $selectedAccount,
            }).once(`error`, () => {
                // TODO
            }).once(`transactionHash`, () => {
                // TODO
            }).once(`receipt`, async (receipt) => {
                const contractToken = await new $web3.eth.Contract(MockBUCK.abi, addressMockBUCK);
                const dataBalance = await contractToken.methods.balanceOf($selectedAccount).call();
                balance = $web3.utils.fromWei(dataBalance, `ether`);

                const dataStake = await contractFarm.methods.getStakeByUser($selectedAccount).call();
                stake = $web3.utils.fromWei(dataStake, `ether`);
            });
        } else {
            Swal.fire(`You aren't staking enough BUCK to do this!`);
        }
    };

    onMount(async () => {
        await defaultChainStore.setBrowserProvider();

        const contractToken = await new $web3.eth.Contract(MockBUCK.abi, addressMockBUCK);
        const dataBalance = await contractToken.methods.balanceOf($selectedAccount).call();
        balance = $web3.utils.fromWei(dataBalance, `ether`);

        const dataAllowance = await contractToken.methods.allowance($selectedAccount, addressArbazaar).call();
        allowance = $web3.utils.fromWei(dataAllowance, `ether`);

        const contractFarm = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
        const dataStake = await contractFarm.methods.getStakeByUser($selectedAccount).call();
        stake = $web3.utils.fromWei(dataStake, `ether`);
    });
</script>

<h2>My Balance</h2>

<h3 class="value">
    <img class="buck" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0xAFD871f684F21Ab9D7137608C71808f83D75e6fc/logo.png" alt="BUCK" loading="lazy">
    {balance}
</h3>

<h2>My Stake</h2>

<h3 class="value">
    <img class="buck" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0xAFD871f684F21Ab9D7137608C71808f83D75e6fc/logo.png" alt="BUCK" loading="lazy">
    {stake}
</h3>

<div class="flex">
    <div class="flex__item">
        <h2>Add Stake</h2>
        <input type="text" bind:value={amountAdd}>
        <div class="flex">
            {#if allowance == 0}
                <button class="primary" on:click={approveTokens}>
                    {#if approving === false}
                        Approve BUCK
                    {:else}
                        Approving...
                    {/if}
                </button>
            {:else}
                <button class="primary" on:click={addStake}>
                    Add
                </button>
            {/if}
        </div>
    </div>
    <div class="flex__item">
        <h2>Remove Stake</h2>
        <input type="text" bind:value={amountRemove}>
        <div class="flex">
            <button class="primary" on:click={removeStake}>
                Remove
            </button>
        </div>
    </div>
</div>

<style>
    .value {
        align-items: center;
        display: flex;
        justify-content: center;
        .value__number {
            font-size: 48px;
            font-weight: 500;
        }
        img {
            border-radius: 50%;
            height: 32px;
            margin-right: 16px;
            width: 32px;
        }
    }
    .flex {
        align-items: center;
        display: flex;
        flex-direction: column;
        row-gap: 16px;
        justify-content: center;
    }
    input {
        background-color: var(--bg);
        border: 0;
        border-radius: 24px;
        box-shadow: rgba(0, 0, 0, .24) 0 1px 4px;
        color: var(--fg);
        font-family: var(--font) !important;
        font-size: 20px;
        margin-bottom: 16px;
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
    .primary {
        font-size: 18px;
        padding: 8px;
        max-width: 180px;
    }
    @media (min-width: 768px) {
        .flex {
            align-items: center;
            column-gap: 16px;
            display: flex;
            flex-direction: row;
            justify-content: center;
        }
    }
</style>

