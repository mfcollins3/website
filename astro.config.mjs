// @ts-check
import { defineConfig } from 'astro/config';
import iubenda from 'astro-iubenda';
import mdx from '@astrojs/mdx';

// https://astro.build/config
export default defineConfig({
    site: 'https://michaelfcollins3.dev',
    integrations: [
        iubenda({
            documentIds: ['37453753'],
            cookieFooter: {
                iubendaOptions: {
                    siteId: 3855737,
                    cookiePolicyId: 37453753,
                    lang: 'en',
                },
            }
        }),
        mdx(),
    ]
});
