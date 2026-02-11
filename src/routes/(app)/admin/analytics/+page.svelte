<script>
	import { goto } from '$lib/utils/navigation';
	import { onMount } from 'svelte';

	import Evaluations from '$lib/components/admin/Evaluations.svelte';

	onMount(() => {
		goto('/admin/evaluations/leaderboard');
	});
</script>

<Evaluations />
