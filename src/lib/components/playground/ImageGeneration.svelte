<script lang="ts">
	import { toast } from 'svelte-sonner';
	import { goto } from '$lib/utils/navigation';
	import { onMount, getContext } from 'svelte';
	import { WEBUI_BASE_URL } from '$lib/constants';
	import { user, models, settings, config } from '$lib/stores';
	import { imageGenerations, getImageGenerationModels } from '$lib/apis/images';
	import Selector from '$lib/components/chat/ModelSelector/Selector.svelte';
	import Image from '$lib/components/common/Image.svelte';

	const i18n = getContext('i18n');

	let loaded = false;
	let prompt = '';
	let negativePrompt = '';
	let size = '1024x1024';
	let n = 1;

	let selectedModelId = '';
	let imageModels: { id: string; name: string }[] = [];

	let loading = false;
	let generatedImages: { url: string }[] = [];

	const loadModels = async () => {
		try {
			const res = await getImageGenerationModels(localStorage.token);
			if (res) {
				imageModels = res;
				if (imageModels.length > 0 && !selectedModelId) {
					selectedModelId = imageModels[0].id;
				}
			}
		} catch (e) {
			console.error('Failed to load image models:', e);
		}
	};

	const submitHandler = async () => {
		if (!prompt.trim()) {
			toast.error($i18n.t('Please enter a prompt'));
			return;
		}

		loading = true;
		generatedImages = [];

		try {
			const res = await imageGenerations(localStorage.token, prompt, {
				model: selectedModelId || undefined,
				size: size || undefined,
				n: n,
				negative_prompt: negativePrompt || undefined
			});

			if (res) {
				generatedImages = res;
			}
		} catch (e) {
			toast.error(typeof e === 'string' ? e : $i18n.t('Failed to generate image'));
			console.error(e);
		} finally {
			loading = false;
		}
	};

	onMount(async () => {
		if ($user?.role !== 'admin') {
			await goto('/');
		}

		await loadModels();
		loaded = true;
	});
</script>

<div class="flex flex-col justify-between w-full overflow-y-auto h-full">
	<div class="mx-auto w-full md:px-0 h-full">
		<div class="flex flex-col h-full px-4">
			<!-- Model & Settings -->
			<div class="flex flex-col gap-2 mb-2">
				<div class="flex flex-col gap-1 w-full">
					<div class="flex w-full">
						<div class="overflow-hidden w-full">
							<div class="max-w-full">
								{#if imageModels.length > 0}
									<Selector
										placeholder={$i18n.t('Select a model')}
										items={imageModels.map((model) => ({
											value: model.id,
											label: model.name ?? model.id,
											model: model
										}))}
										bind:value={selectedModelId}
									/>
								{:else}
									<Selector
										placeholder={$i18n.t('Select a model')}
										items={$models.map((model) => ({
											value: model.id,
											label: model.name,
											model: model
										}))}
										bind:value={selectedModelId}
									/>
								{/if}
							</div>
						</div>
					</div>

					<!-- Size & Count -->
					<div class="flex gap-2 items-center text-sm">
						<label class="flex items-center gap-1 text-gray-500 dark:text-gray-400">
							{$i18n.t('Size')}
							<select
								bind:value={size}
								class="bg-transparent border border-gray-100/30 dark:border-gray-850/30 rounded-lg px-2 py-1 text-sm outline-none"
							>
								<option value="256x256">256x256</option>
								<option value="512x512">512x512</option>
								<option value="1024x1024">1024x1024</option>
								<option value="1024x1792">1024x1792</option>
								<option value="1792x1024">1792x1024</option>
							</select>
						</label>

						<label class="flex items-center gap-1 text-gray-500 dark:text-gray-400">
							{$i18n.t('Count')}
							<input
								type="number"
								bind:value={n}
								min="1"
								max="4"
								class="w-16 bg-transparent border border-gray-100/30 dark:border-gray-850/30 rounded-lg px-2 py-1 text-sm outline-none"
							/>
						</label>
					</div>
				</div>
			</div>

			<!-- Prompt & Results Area -->
			<div
				class="pt-0.5 pb-2.5 flex flex-col justify-between w-full flex-auto overflow-auto h-0 gap-2"
			>
				<!-- Prompt -->
				<div class="flex flex-col gap-2">
					<textarea
						class="w-full p-3 bg-transparent border border-gray-100/30 dark:border-gray-850/30 outline-hidden resize-none rounded-lg text-sm"
						bind:value={prompt}
						placeholder={$i18n.t('Describe the image you want to generate...')}
						rows="3"
						on:keydown={(e) => {
							if (e.key === 'Enter' && !e.shiftKey) {
								e.preventDefault();
								submitHandler();
							}
						}}
					/>

					<textarea
						class="w-full p-3 bg-transparent border border-gray-100/30 dark:border-gray-850/30 outline-hidden resize-none rounded-lg text-sm text-gray-500"
						bind:value={negativePrompt}
						placeholder={$i18n.t('Negative prompt (optional)')}
						rows="2"
					/>
				</div>

				<!-- Generated Images -->
				{#if generatedImages.length > 0}
					<div
						class="flex-1 grid gap-4 overflow-y-auto"
						style="grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));"
					>
						{#each generatedImages as image}
							<div
								class="rounded-lg overflow-hidden border border-gray-100/30 dark:border-gray-850/30"
							>
								<Image src={image.url} alt={prompt} imageClassName="w-full h-auto rounded-lg" />
							</div>
						{/each}
					</div>
				{:else if loading}
					<div class="flex-1 flex items-center justify-center">
						<div class="flex flex-col items-center gap-2 text-gray-400">
							<svg
								class="animate-spin size-8"
								xmlns="http://www.w3.org/2000/svg"
								fill="none"
								viewBox="0 0 24 24"
							>
								<circle
									class="opacity-25"
									cx="12"
									cy="12"
									r="10"
									stroke="currentColor"
									stroke-width="4"
								/>
								<path
									class="opacity-75"
									fill="currentColor"
									d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
								/>
							</svg>
							<span class="text-sm">{$i18n.t('Generating...')}</span>
						</div>
					</div>
				{:else}
					<div class="flex-1 flex items-center justify-center">
						<span class="text-sm text-gray-400 dark:text-gray-600"
							>{$i18n.t('Generated images will appear here')}</span
						>
					</div>
				{/if}
			</div>

			<!-- Actions -->
			<div class="pb-3 flex justify-end">
				<button
					class="px-3.5 py-1.5 text-sm font-medium bg-black hover:bg-gray-900 text-white dark:bg-white dark:text-black dark:hover:bg-gray-100 transition rounded-full disabled:opacity-50 disabled:cursor-not-allowed"
					on:click={submitHandler}
					disabled={loading || !prompt.trim()}
				>
					{#if loading}
						{$i18n.t('Generating...')}
					{:else}
						{$i18n.t('Generate')}
					{/if}
				</button>
			</div>
		</div>
	</div>
</div>
