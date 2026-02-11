<script>
	import { base } from '$app/paths';
	import { shortCodesToEmojis } from '$lib/stores';

	export let shortCode;
	export let className = 'size-4';
</script>

{#if $shortCodesToEmojis[shortCode]}
	<img
		src="{base}/assets/emojis/{$shortCodesToEmojis[shortCode].toLowerCase()}.svg"
		alt={shortCode}
		class={className}
		loading="lazy"
	/>
{:else}
	<div>
		{shortCode}
	</div>
{/if}
