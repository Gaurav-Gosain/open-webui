<script lang="ts">
	import { goto } from '$lib/utils/navigation';
	import { onMount } from 'svelte';

	onMount(() => {
		goto('/admin/users');
	});
</script>
