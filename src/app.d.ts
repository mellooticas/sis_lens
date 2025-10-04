// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}
	
	interface ImportMetaEnv {
		readonly VITE_SUPABASE_URL: string;
		readonly VITE_SUPABASE_ANON_KEY: string;
		readonly VITE_APP_NAME: string;
		readonly VITE_APP_VERSION: string;
		readonly VITE_APP_ENVIRONMENT: string;
	}
	
	interface ImportMeta {
		readonly env: ImportMetaEnv;
	}
}

export {};
