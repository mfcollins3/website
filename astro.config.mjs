// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import { remarkReadingTime } from './remark-reading-time.mjs';
import { remarkModifiedTime } from './remark-modified-time.mjs';

import utc from 'dayjs/plugin/utc';
import timezone from 'dayjs/plugin/timezone';
import dayjs from 'dayjs';

dayjs.extend(utc);
dayjs.extend(timezone);

// https://astro.build/config
export default defineConfig({
  site: 'https://michaelfcollins3.dev',
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    remarkPlugins: [
      remarkReadingTime,
      remarkModifiedTime
    ],
  },
});
