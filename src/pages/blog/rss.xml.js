import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
    const allPosts = await getCollection('blog', (post) => import.meta.env.PROD ? !post.data.draft : true);
    const sortedPosts = allPosts.sort(
        (a, b) => b.data.publishedDate.getTime() - a.data.publishedDate.getTime()
    );

    return rss({
        title: 'Articles from Michael F. Collins, III',
        description: 'Articles (mostly) on software development and architecture, and other technical topics.',
        site: context.site,
        items: sortedPosts.map((post) => ({
            title: post.data.title,
            description: post.data.description,
            pubDate: post.data.publishedDate,
            link: `/blog/${post.id}/`,
        })),
        customData: '<language>en-us</language>'
    });
}
