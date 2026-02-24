import { defineCollection, z } from 'astro:content';
import { glob, file } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '*.{md,mdx}', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    excerpt: z.string(),
    featuredImage: z.string().optional(),
    publishedDate: z.coerce.date(),
    readTime: z.number(),
    tags: z.array(z.string()).default([]),
    categories: z.array(z.string()).default([]),
    isFeatured: z.boolean().optional().default(false),
  }),
});

const projects = defineCollection({
  loader: file('./src/content/projects/projects.json'),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    thumbnail: z.string().optional(),
    githubUrl: z.string().url(),
    websiteUrl: z.string().url().optional(),
    technologies: z.array(z.string()).default([]),
  }),
});

const recipes = defineCollection({
  loader: file('./src/content/recipes/recipes.json'),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    image: z.string().optional(),
    prepTime: z.number(),
    cookTime: z.number(),
    servings: z.number(),
    ingredients: z.array(z.string()),
    instructions: z.array(z.string()),
  }),
});

export const collections = { blog, projects, recipes };
