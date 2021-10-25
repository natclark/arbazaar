<script>
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';
    import Modal from 'svelte-simple-modal';
    import ManageStakeButton from '$lib/components/ManageStakeButton.svelte';
    import { onMount } from 'svelte';
    import MockBUCK from '$lib/abi/MockBUCK.json';
    import Arbazaar from '$lib/abi/Arbazaar.json';
    import { addressMockBUCK, addressArbazaar } from '../../../config';

    let total = 0;
    let balance = 0;
    let stake = 0;
    let rewards = 0;

    let claiming = false;

    const claimRewards = async () => {
        if (!!$connected) {
            if (rewards > 0) {
                claiming = true;

                const contractFarm = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
                const dataTotal = await contractFarm.methods.claimRewards().send({
                    from: $selectedAccount,
                }).once(`error`, () => {
                    // TODO
                    claiming = false;
                }).once(`transactionHash`, () => {
                    // TODO
                }).once(`receipt`, async (receipt) => {
                    const dataRewards = await contractFarm.methods.getUnclaimedRewardsByUser($selectedAccount).call();
                    rewards = $web3.utils.fromWei(dataRewards, `ether`);
                    claiming = false;
                });
            } else {
                Swal.fire(`There aren't any rewards for you to claim right now!`);
            }
        }
    };

    const connectWallet = () => {
        if (typeof window.ethereum !== `undefined`) {
            defaultChainStore.setBrowserProvider();
        } else {
            Swal.fire(`You must have a web3-enabled Ethereum wallet like Metamask to do this!`);
        }
    };

    const refresh = async () => {
        if (!!$connected) {
            const contractFarm = await new $web3.eth.Contract(Arbazaar.abi, addressArbazaar);
            const dataTotal = await contractFarm.methods.getStakeTotal().call();
            total = $web3.utils.fromWei(dataTotal, `ether`);

            const dataStake = await contractFarm.methods.getStakeByUser($selectedAccount).call();
            stake = $web3.utils.fromWei(dataStake, `ether`);

            const dataRewards = await contractFarm.methods.getUnclaimedRewardsByUser($selectedAccount).call();
            rewards = $web3.utils.fromWei(dataRewards, `ether`);

            const contractToken = await new $web3.eth.Contract(MockBUCK.abi, addressMockBUCK);
            const dataBalance = await contractToken.methods.balanceOf($selectedAccount).call();
            balance = $web3.utils.fromWei(dataBalance, `ether`);
        }
    };

    onMount(() => {
        refresh();
    });

    $: $connected, typeof document !== `undefined` && (refresh());
</script>

<svelte:head>
    <title>Staking - Arbazaar</title>
</svelte:head>

<h1>Stake BUCK. Farm ETH.</h1>
<p class="subtitle">No inflation, impermanent loss, or "ponzinomics".</p>

<div class="card">
    <h2>Total BUCK Staked</h2>
    <p class="value">
        <img class="buck" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0xAFD871f684F21Ab9D7137608C71808f83D75e6fc/logo.png" alt="BUCK" loading="lazy">
        <span class="value__number">
            {new Intl.NumberFormat(`en-US`).format(total)}
        </span>
    </p>
</div>

<div class="flex">
    <div class="flex__card">
        <h2>My Stake</h2>
        <p class="value">
            <img class="buck" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0xAFD871f684F21Ab9D7137608C71808f83D75e6fc/logo.png" alt="BUCK" loading="lazy">
            <span class="value__number">
                {new Intl.NumberFormat(`en-US`).format(stake)}
            </span>
        </p>
    </div>
    <div class="flex__card">
        <h2>My Rewards</h2>
        <p class="value">
            <img class="eth" src="https://raw.githubusercontent.com/sushiswap/assets/master/blockchains/arbitrum/assets/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1/logo.png" alt="ETH" loading="lazy">
            <span class="value__number">
                {rewards}
            </span>
        </p>
    </div>
</div>

<div class="flex">
    {#if !!$connected}
        <div class="flex__button">
            <Modal>
                <ManageStakeButton />
            </Modal>
            <button class="primary" on:click={claimRewards}>
                {#if claiming === false}
                    Claim Rewards
                {:else}
                    Claiming...
                {/if}
            </button>
        </div>
    {:else}
        <div class="flex__button">
            <button class="primary" on:click={connectWallet}>
                Connect Wallet
            </button>
        </div>
    {/if}
</div>

<div class="flex">
    <div class="flex__text">
        <h2>What?! Where is the ETH coming from?</h2>
        <p>You can't just print free ETH out of thin air. BUCK is a fixed supply token, and ETH isn't inflationary either. So how does this work?</p>
        <p>Well, unlike your typical <del>ponzi</del> <ins>yield farm</ins>, Arbazaar has a real product that actually provides value to the ecosystem. Every time an NFT sale is made on Arbazaar, 2% of the purchase price is proportionally distributed to BUCK stakers. (And 0.5% goes to the developer wallet.)</p>
        <p>Here's an example. Let's say 1,000,000 BUCK tokens are staked on Arbazaar, and your personal stake is 200,000 BUCK tokens. In this scenario, you would earn 0.2% of every Arbazaar sale, in ETH.</p>
    </div>
    <div class="flex__text">
        <h2>How can I claim my ETH rewards?</h2>
        <p>ETH rewards must be claimed manually. From this interface, you can claim your ETH rewards in a few quick steps.</p>
        <p>First, connect the Ethereum wallet you've used to stake your tokens, and ensure you're on the Arbitrum network.</p>
        <p>Then, click the "Claim Rewards" button. You'll be prompted to initiate a transaction and pay a small gas fee to claim any outstanding ETH rewards that you have earned since your previous claim.</p>
        <p>Lastly, just wait a moment for the ETH to appear in your wallet!</p>
        <p><strong>If you unstake your BUCK while you still have unclaimed ETH rewards, you can still claim your unclaimed ETH even after you unstake.</strong></p>
    </div>
</div>

<div class="flex">
    <div class="flex__text">
        <h2>How do I know my BUCK tokens are safe?</h2>
        <p>The code for the staking contract is open-source, and you can decide for yourself whether you want to stake your tokens. While the Arbazaar team cannot run away with your staked tokens, there is intrinsic risk associated with staking and you should use precaution and never rush into anything.</p>
    </div>
    <div class="flex__text">
        <h2>What if this website shuts down? How would I withdraw my BUCK and claim my rewards?</h2>
        <p>One way is to download the source code of this website, run it on your own computer, and unstake your tokens using this same portal locally.</p>
        <p>However, you can always interact with the contract directly to claim your rewards manually.</p>
    </div>
</div>

<style>
    .flex {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        margin-bottom: 60px;
        row-gap: 16px;
        text-align: left;
        .flex__card {
            background-color: var(--bg-soft);
            border-radius: 8px;
            padding: 4px 24px;
            width: 100%;
        }
        .flex__button {
            display: flex;
            justify-content: space-around;
            width: 100%;
        }
        .flex__text {
            width: 100%;
            h2 {
                text-align: left !important;
            }
        }
    }
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
    ins {
        text-decoration: none;
    }
    @media screen and (min-width: 768px) {
        .flex {
            flex-direction: row;
            column-gap: 16px;
        }
    }
</style>
