<script context="module">
    import { browser } from '$app/env';
    export const hydrate = true;
    export const router = browser;
    export const prerender = false;
</script>

<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import Navbar from '$lib/components/Navbar.svelte';
    import Alert from '$lib/components/Alert.svelte';
    import Wrapper from '$lib/components/Wrapper.svelte';
    import Footer from '$lib/components/Footer.svelte';
    import '$lib/global.scss';
    import 'skeleton-elements/skeleton-elements.css';
    import '@sweetalert2/theme-dark/dark.css';

    onMount(() => {
        (window.location.href.includes(`/assets/`)) && (goto(window.location.href));
        (window.location.href.includes(`/collection/`)) && (goto(window.location.href));
        (window.location.href.includes(`/accounts/`)) && (goto(window.location.href));
    });
</script>

<Navbar />

<Wrapper>
    <div class="content">
        <Alert />
        <slot />
    </div>
</Wrapper>

<!--
<Footer />
-->

<style>
    .content {
        margin-top: 80px;
        max-width: 1200px;
        padding: 0 20px;
        text-align: center;
        width: 100%;
    }
</style>
