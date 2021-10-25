<script>
    import { onMount } from 'svelte';
    import { page } from '$app/stores';
    import { goto } from '$app/navigation';
    import AutoComplete from 'simple-svelte-autocomplete';

    let select;

    let selectedItem;
    let selectedValue;

    $: selectedValue, (typeof selectedValue !== `undefined` && selectedToken !== null) && (newChart());
</script>

<div bind:this={select} class="select">
    <AutoComplete items={[]} bind:selectedItem={selectedItem} bind:value={selectedValue} labelFieldName="Symbol" valueFieldName="Address" placeholder="Collection, item, or account">
        <div slot="item" let:item={item}>
            <div class="select__item">
                <div class="select__item__image">
                    <img src={`/placeholder.png`} width="32px" height="32px" alt="" aria-hidden="true">
                </div>
                <div class="select__item__text"></div>
            </div>
        </div>
        <div slot="no-results">
            <strong>NO RESULTS</strong>
        </div>
    </AutoComplete>
</div>

<style global>
    .select {
        align-items: center;
        display: flex;
        justify-content: flex-end;
        width: 100%;
        .select__item {
            align-items: center;
            display: flex;
            justify-content: space-between;
            margin: 8px;
            .select__item__image {
                margin-top: 2px;
                width: 20%;
            }
            .select__item__text {
                display: block;
                text-align: left !important;
                width: 80%;
                p {
                    margin: 0;
                    &.select__item__text__symbol {
                        font-weight: 700;
                        margin-bottom: 4px;
                    }
                    &.select__item__text__name {
                        font-size: 14px;
                    }
                }
            }
        }
        .autocomplete::after {
            border-color: var(--fg) !important;
            border-width: 2px !important;
        }
        input {
            background-color: var(--bg-soft);
            border: 0;
            border-radius: 24px;
            box-shadow: rgba(0, 0, 0, .24) 0 1px 4px;
            color: var(--fg);
            font-family: var(--font) !important;
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
        .autocomplete-list {
            background-color: var(--bg-soft) !important;
            border: 0 !important;
            border-radius: 24px;
            max-height: 200px !important;
            max-width: 800px;
            outline: none !important;
            scrollbar-color: var(--fg-scroll) var(--bg-scroll);
            scrollbar-face-color: var(--fg-scroll);
            scrollbar-track-color: var(--bg-scroll);
            scrollbar-width: thin;
            .autocomplete-list-item {
                color: var(--fg) !important;
                will-change: background-color, color;
                .select__item {
                    margin: 0;
                }
                &.selected, &:hover {
                    background-color: var(--bg-hover);
                    color: #fff !important;
                }
            }
            ::-webkit-scrollbar {
                width: 8px;
            }
            ::-webkit-scrollbar-corner, ::-webkit-scrollbar-track {
                background-color: var(--bg-scroll);
                border-radius: 24px;
            }
            ::-webkit-scrollbar-thumb {
                background-image: var(--gr-scroll);
                border-radius: 24px;
            }
        }
    }
</style>
