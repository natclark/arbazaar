<script>
    import { onMount } from 'svelte';
    import { page } from '$app/stores';
    import Search from './Search.svelte';
    import { defaultChainStore, web3, selectedAccount, connected, chainData } from 'svelte-web3';
    import Swal from 'sweetalert2';

    let doc;

    let menu;

    const close = (e) => {
        menu.removeAttribute(`open`);
    };

    const connectWallet = async () => {
        await defaultChainStore.setBrowserProvider();
    };
</script>

<svelte:body on:click={close} />

<nav>
    <div class="left">
        <a class="logo" href="/" title="Home" draggable="false" aria-current="{$page.path === `/` ? `page` : ``}" sveltekit:prefetch>
            <img draggable="false" src="/img/arbucks-logo.svg" alt="Arbucks Logo" width="40px" height="40px">
            &nbsp; Arbazaar
        </a>
    </div>
    <div class="center">
        <div class="search">
            <!--
            <Search />
            -->
        </div>
    </div>
    <div class="right">
        <details bind:this={menu} class="menu menu--mobile">
            <summary>
                <svg width="26px" height="26px" viewBox="0 0 122.88 102.4">
                    <title>Menu</title>
                    <path fill-rule="evenodd" d="M35.37,0h86a1.56,1.56,0,0,1,1.55,1.55V20.21a1.58,1.58,0,0,1-1.55,1.54h-86a1.56,1.56,0,0,1-1.54-1.54V1.55A1.54,1.54,0,0,1,35.37,0Zm0,80.65h86a1.56,1.56,0,0,1,1.55,1.54v18.67a1.58,1.58,0,0,1-1.55,1.54h-86a1.56,1.56,0,0,1-1.54-1.54V82.19a1.54,1.54,0,0,1,1.54-1.54Zm-33.82,0h16a1.56,1.56,0,0,1,1.55,1.54v18.67a1.58,1.58,0,0,1-1.55,1.54h-16A1.56,1.56,0,0,1,0,100.86V82.19a1.54,1.54,0,0,1,1.55-1.54ZM35.37,62.08h86a1.56,1.56,0,0,0,1.55-1.55V41.87a1.58,1.58,0,0,0-1.55-1.55h-86a1.57,1.57,0,0,0-1.54,1.55V60.53a1.55,1.55,0,0,0,1.54,1.55Zm-33.82,0h16a1.56,1.56,0,0,0,1.55-1.55V41.87a1.58,1.58,0,0,0-1.55-1.55h-16A1.57,1.57,0,0,0,0,41.87V60.53a1.55,1.55,0,0,0,1.55,1.55ZM1.55,0h16A1.56,1.56,0,0,1,19.1,1.55V20.21a1.58,1.58,0,0,1-1.55,1.54h-16A1.56,1.56,0,0,1,0,20.21V1.55A1.54,1.54,0,0,1,1.55,0Z"></path>
                </svg>
            </summary>
            <div class="menu__links">
                <!--
                    <a href="/bridge/" draggable="false" aria-current="{$page.path === `/bridge/` ? `page` : ``}" sveltekit:prefetch>Bridge</a>
                -->
                <a href="/listings/" draggable="false" aria-current="{$page.path === `/listings/` ? `page` : ``}" sveltekit:prefetch>Listings</a>
                <a href="/create/" draggable="false" aria-current="{$page.path === `/create/` ? `page` : ``}" sveltekit:prefetch>Create</a>
                <a href="/stake/" draggable="false" aria-current="{$page.path === `/stake/` ? `page` : ``}" sveltekit:prefetch>Stake</a>
                {#if $selectedAccount !== null}
                    <a href="/accounts/{$selectedAccount}/" draggable="false" aria-current="{$page.path === `/accounts/{$selectedAccount}/` ? `page` : ``}" sveltekit:prefetch>
                        Profile
                    </a>
                {:else}
                    <a role="button" draggable="false" on:click={connectWallet}>
                        Connect
                    </a>
                {/if}
            </div>
        </details>
        <div class="menu menu--desktop">
            <!--
                <a href="/bridge/" draggable="false" aria-current="{$page.path === `/bridge/` ? `page` : ``}" sveltekit:prefetch>Bridge</a>
            -->
            <a href="/listings/" draggable="false" aria-current="{$page.path === `/listings/` ? `page` : ``}" sveltekit:prefetch>Listings</a>
            <a href="/create/" draggable="false" aria-current="{$page.path === `/create/` ? `page` : ``}" sveltekit:prefetch>Create</a>
            <a href="/stake/" draggable="false" aria-current="{$page.path === `/stake/` ? `page` : ``}" sveltekit:prefetch>Stake</a>
            {#if $selectedAccount !== null}
                <a class="secondary" href="/accounts/{$selectedAccount}/" draggable="false" aria-current="{$page.path === `/accounts/{$selectedAccount}/` ? `page` : ``}" sveltekit:prefetch>
                    <svg version="1.1" height="20px" width="20px" x="0px" y="0px" viewBox="0 0 200 200" style="enable-background:new 0 0 200 200;" xml:space="preserve">
                        <g>
                            <g>
                                <path fill="#fff" d="M143.1,64.2H134V49.4c0-7.3-5.9-13.2-13.2-13.2H79.2c-7.3,0-13.2,5.9-13.2,13.2v14.8h-9.1V49.4    c0-12.3,10-22.2,22.2-22.2h41.6c12.3,0,22.2,10,22.2,22.2V64.2z" />
                            </g>
                            <g>
                                <path fill="#fff" d="M145.5,172.9H54.5c-16.5,0-29.9-13.4-29.9-29.9V89.6c0-16.5,13.4-29.9,29.9-29.9h90.9    c16.5,0,29.9,13.4,29.9,29.9V143C175.4,159.5,161.9,172.9,145.5,172.9z M54.5,68.7c-11.5,0-20.8,9.4-20.8,20.8V143    c0,11.5,9.4,20.8,20.8,20.8h90.9c11.5,0,20.8-9.4,20.8-20.8V89.6c0-11.5-9.4-20.8-20.8-20.8H54.5z" />
                            </g>
                        </g>
                    </svg>
                    Profile
                </a>
            {:else}
                <a class="secondary" role="button" draggable="false" on:click={connectWallet}>
                    Connect
                </a>
            {/if}
        </div>
    </div>
</nav>

<style>
    nav {
        align-items: center;
        background-color: #000;
        display: flex;
        height: 80px;
        justify-content: space-between;
        position: fixed;
        top: 0;
        width: 100%;
        z-index: 999;
        .left, .right {
            align-items: center;
            display: flex;
            justify-content: space-between;
            width: 380px;
            a:not(.secondary) {
                align-items: center;
                border-radius: 4px;
                color: var(--fg);
                display: flex;
                font-size: 20px;
                font-weight: 400;
                height: 36px;
                overflow: hidden;
                padding: 0 8px;
                position: relative;
                text-decoration: none;
                will-change: text-shadow;
                svg:not(.nofill) path {
                    fill: var(--fg-fill);
                }
                &[aria-current="page"]:not(.logo) {
                    font-weight: 700;
                }
                &.highlight {
                    margin-left: 0;
                }
                &:hover {
                    text-shadow: 0 0 16px #fff, 0 0 8px #ccc;
                }
            }
            summary {
                svg {
                    margin-top: -2px;
                    &:not(.nofill) path {
                        fill: var(--fg-fill);
                    }
                }
            }
            button:not(.secondary) {
                align-items: center;
                background-color: transparent;
                border: 0;
                border-radius: 4px;
                cursor: pointer;
                display: flex;
                height: 40px;
                margin: 0;
                overflow: hidden;
                padding: 0 8px;
                position: relative;
                svg:not(.nofill) path {
                    fill: var(--fg-fill);
                }
                &:hover {
                    background-color: var(--bg-hover);
                }
            }
        }
        .left {
            a {
                &.logo {
                    height: 40px;
                    will-change: opacity, transform;
                    span {
                        font-size: 8px;
                    }
                    &:hover {
                        opacity: .8;
                    }
                    &:active {
                        transform: scale(.97);
                    }
                }
            }
            .small {
                align-items: center;
                display: flex;
                font-size: 12px;
                a {
                    font-size: 12px;
                }
            }
            summary {
                align-items: center;
                cursor: pointer;
                display: flex;
                font-size: 20px;
                font-weight: 700;
                height: 40px;
                list-style-type: none;
                margin-left: 12px;
                overflow: hidden;
                padding: 2px 8px 0;
                position: relative;
                &::-webkit-details-marker, &::marker { /* supposedly, -webkit-details-marker isn't supported anymore? */
                    display: none;
                }
                &:hover {
                    background-color: var(--bg-hover);
                }
            }
        }
        .center {
            max-width: 600px;
            width: 100%;
        }
        .search {
            display: none;
        }
        .right {
            justify-content: flex-end;
            .menu {
                &.menu--mobile {
                    display: block;
                    margin-right: 12px;
                    .menu__links {
                        background-color: var(--bg-soft);
                        left: 0;
                        position: fixed;
                        right: 0;
                        top: 70px;
                        width: 100vw;
                        z-index: 1;
                    }
                }
                &.menu--desktop {
                    display: none;
                    a {
                        margin-left: 12px;
                    }
                }
            }
            a:not(.secondary) {
                margin-left: 12px;
                &.icon {
                    height: 40px;
                    margin-left: 0;
                    &:hover {
                        background-color: var(--bg-hover);
                    }
                }
            }
            details {
                align-items: stretch;
                display: flex;
                flex-grow: 0;
                flex-shrink: 0;
                margin-left: 12px;
                position: relative;
                summary {
                    cursor: pointer;
                    display: flex;
                    list-style-type: none;
                    position: relative;
                    will-change: opacity;
                    &:hover {
                        opacity: .8;
                    }
                    &::-webkit-details-marker, &::marker { /* supposedly, -webkit-details-marker isn't supported anymore? */
                        display: none;
                    }
                    &::after {
                        border-radius: 2px;
                        content: ' ';
                        display: block;
                        pointer-events: none;
                        position: absolute;
                    }
                }
            }
        }
    }
    .secondary {
        svg {
            height: 20px;
            margin: 0 6px 2px 0;
            width: 20px;
        }
    }
    @media screen and (min-width: 1024px) {
        nav {
            justify-content: space-around;
            .right {
                display: flex;
                justify-content: flex-end;
            }
        }
        .menu {
            &.menu--mobile {
                display: none !important;
            }
            &.menu--desktop {
                display: flex !important;
            }
        }
        .submenu.submenu--mobile {
            display: none;
        }
        .search {
            display: block !important;
            margin-bottom: 4px;
        }
        .secondary {
            font-size: 20px;
            height: 36px;
            margin-left: 12px;
        }
    }
    :global {
        .search {
            .autocomplete {
                .input-container input {
                    font-size: 16px !important;
                    line-height: 20px !important;
                }
                &:not(.hide-arrow):not(.is-loading):after {
                    top: 45% !important;
                }
            }
        }
    }
</style>
