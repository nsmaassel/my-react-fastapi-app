/// <reference types="vite/client" />

interface ImportMetaEnv {
    readonly VITE_API_URL: string
}

interface ImportMeta {
    readonly env: ImportMetaEnv
}

interface Window {
    env?: {
        VITE_API_URL?: string;
    }
}

declare global {
    interface Window {
        env?: {
            VITE_API_URL?: string;
        }
    }
}
