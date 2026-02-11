<script lang="ts">
	import { base } from '$app/paths';

	export let className = 'size-8';
	export let src = `${base}/static/favicon.png`;

	const fallback = `${base}/static/favicon.png`;
</script>

<img
	aria-hidden="true"
	src={src === '' || src.includes('undefined')
		? fallback
		: src.startsWith(base) ||
			  src.startsWith('https://www.gravatar.com/avatar/') ||
			  src.startsWith('data:') ||
			  src.startsWith('/')
			? src
			: `${base}/user.png`}
	class=" {className} object-cover rounded-full"
	alt="profile"
	draggable="false"
	on:error={(e) => { e.currentTarget.src = fallback; }}
/>
