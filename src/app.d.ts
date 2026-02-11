// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces

// Vite compile-time constants (see vite.config.ts `define`)
declare const APP_VERSION: string;
declare const APP_BUILD_HASH: string;
declare const APP_BASE_PATH: string;

declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface Platform {}
	}
}

export {};
