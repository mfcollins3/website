# michaelfcollins3.dev - Product Requirements Document

## 1. Product overview

### 1.1 Problem statement

Michael F. Collins, III needs a single, authoritative web presence that
represents his personal and professional brand to the software engineering
community and to potential employers. Today his identity is spread across
multiple social networks with no central hub for long-form writing,
credentials, or a coherent narrative. The site must launch quickly so that he
can begin building an audience around the technical writing he is already
producing.

### 1.2 Product vision

A fast, accessible, content-first personal website that is the default place
people land when they want to learn about Michael, read what he is thinking
about, or evaluate him professionally. The site is built to be durable: static
output, owned content, low operational cost, and structured so that humans,
search engines, and LLMs can all consume it well.

### 1.3 Success criteria

- v1.0 is live at `https://michaelfcollins3.dev` on or before **May 3, 2026**.
- Lighthouse scores on the homepage and a representative blog post: **>=95**
  for Performance, Accessibility, Best Practices, and SEO on mobile.
- WCAG 2.1 **Level AA** conformance verified by automated (axe / Lighthouse)
  and manual keyboard testing before launch.
- New blog posts can go from "Markdown file merged to `main`" to "live on
  production" with **no manual deploy step** in under 5 minutes.
- The site renders usable content in terminal browsers (`lynx`, `w3m`) and
  with JavaScript disabled.
- RSS feed, sitemap, and `llms.txt` are discoverable and validate against
  their respective specs.

## 2. User personas

- **Hiring manager / recruiter**: Lands on the homepage from a LinkedIn or
  resume link. Wants to quickly assess seniority, focus areas, and writing
  quality, then download a PDF resume.
- **Peer engineer / community reader**: Arrives from a social share or search
  result for a specific technical topic. Wants to read the article, find
  related posts, and follow Michael on their preferred platform.
- **Returning subscriber**: Already follows Michael via RSS or a social
  channel. Wants the newest post fast, with a clean reading experience on
  mobile and desktop.

## 3. Principles & constraints

### 3.1 Design principles

1. **Content first.** Every layout decision must serve readability of the
   blog. Chrome shrinks, content does not.
2. **Static and portable.** No server runtime. The site must be reproducible
   from the Git repo alone.
3. **Progressive enhancement.** Core content and navigation work without
   JavaScript. JS adds polish (search, consent, analytics), never gates
   content.
4. **Accessible by default.** WCAG 2.1 AA is a launch requirement, not a
   follow-up.
5. **Own the content.** Posts live as Markdown in the repo; third parties
   (analytics, consent, search index) are replaceable.
6. **Ship v1.0 small.** Defer anything that is not the blog, the bio, the
   resume, or the legal/SEO scaffolding.

### 3.2 Technical constraints

- **Framework**: Astro (latest stable) with Content Collections for blog
  posts.
- **Language**: TypeScript for component code; Markdown (`.md`) for posts.
- **Hosting**: GitHub Pages on the `mfcollins3` GitHub account, custom
  domain `michaelfcollins3.dev`.
- **CI/CD**: GitHub Actions builds the Astro site and deploys to GitHub
  Pages on every push to `main`.
- **Search**: Pagefind, generated as a post-build step against the produced
  static HTML.
- **Icons**: Font Awesome Pro using the downloadable Pro kit (CSS +
  webfont/SVG assets) self-hosted from `/public/`. The kit script
  loader and any third-party CDN runtime fetches are not used.
- **Analytics**: Google Analytics 4, lazy-loaded **only after** the user
  grants cookie consent through iubenda.
- **Consent / legal**: iubenda site ID `37453753` for cookie banner,
  privacy policy, and cookie policy.
- **Browsers**: First-class support for the latest two stable versions of
  Chrome, Edge, and Safari (desktop and mobile). Best-effort support for
  current Firefox. Core content must remain readable in `lynx`, `w3m`,
  `elinks`, and `browsh`.
- **Performance**: Homepage and blog post initial HTML payload <= 100 KB
  gzipped excluding images; total JS on a blog post page <= 75 KB gzipped.
- **Accessibility**: WCAG 2.1 AA. The brand color `#87CEEB` is the visual
  identity, but cannot be used directly for text or small UI on a white
  background (contrast ~1.8:1). A small derived palette must be defined
  (see section 6.2) with a darker variant for light-mode interactive
  elements; the base color works as-is on dark backgrounds.

### 3.3 Out of scope (v1.0)

The following are intentionally **not** part of v1.0 and AI agents should
not add them:

- Tag, category, or author taxonomy pages.
- Comments (Giscus, Disqus, etc.).
- Social share buttons on posts.
- Estimated reading time.
- Newsletter signup or email capture.
- Projects portfolio, talks, or "uses" pages.
- Per-PR preview deploys - local `astro dev` is the preview environment for v1.0.
- A CMS or admin UI - posts are authored as files in the repo.
- Pagination of blog index pages (deferred until post volume warrants it).
- Multi-language / i18n support.

## 4. Release plan (high level)

### v1.0 - by May 3, 2026 - "Launch"

The blog is live. Visitors can read the featured post and recent posts on
the homepage, browse all posts via year/month archives, search the site,
read the About page, download the resume, and follow Michael via RSS or
social links. Legal, analytics, SEO, and CI/CD are wired up.

### v1.1 - tentative - "Growth"

Pagination on archive indices (once >20 posts exist), tag pages, estimated
reading time, comments, and social share buttons.

### v2.0 - tentative - "Portfolio"

Projects portfolio, talks/speaking page, newsletter signup, and a "uses"
page.

## 5. Current version: v1.0 requirements

### 5.1 Feature: Astro project scaffold and content collection

**User story:** As Michael, I want a clean Astro project with a typed blog
content collection so that I can author posts as Markdown files with
validated frontmatter.

**Acceptance criteria:**

- [ ] Astro project initialized with TypeScript, strict mode.
- [ ] A `blog` content collection is defined under
  `src/content/blog/` with a Zod schema enforcing the frontmatter listed
  below.
- [ ] Each post lives in its own folder so the cover image is co-located
  with the Markdown (e.g.,
  `src/content/blog/<slug>/index.md` + `src/content/blog/<slug>/cover.jpg`).
- [ ] The schema validates the following fields:
  - `title` (string, required)
  - `slug` (string, optional - derived from folder name if absent)
  - `publicationDate` (date, required)
  - `summary` (string, required, 50-300 chars)
  - `coverImage` (image reference, required)
  - `coverAttributionHtml` (string, optional - raw HTML snippet)
  - `author` (string, default `"Michael F. Collins, III"`)
  - `draft` (boolean, default `false`)
  - `featured` (boolean, default `false`)
  - `tags` (string array, optional - stored but not surfaced in v1.0)
  - `openGraph` (object, optional: `title`, `description`, `image`, `type`)
  - `twitter` (object, optional: `card`, `title`, `description`, `image`,
    `creator`)
- [ ] Posts where `draft: true` are excluded from production builds but
  visible in `astro dev`.
- [ ] Build fails with a clear error if a required field is missing or a
  cover image cannot be resolved.

**Technical notes:** Use Astro's `image()` helper in the schema so cover
images are processed and optimized.

**Priority:** Must-have

### 5.2 Feature: Blog post page

**User story:** As a reader, I want to read an individual blog post with
the cover image, title, author, date, summary, and full content so that I
can consume the article without distraction.

**Acceptance criteria:**

- [ ] Route is `/blog/{YYYY}/{MM}/{slug}/` (zero-padded month).
- [ ] Page renders, in this order: cover image, title (h1), author name
  ("Michael F. Collins, III"), publication date (human-readable, with
  machine-readable `<time datetime>`), summary, full Markdown content.
- [ ] Cover image attribution HTML, if present, renders below the cover
  image.
- [ ] Page has a print stylesheet (`@media print`) that hides the global
  header, footer, navigation, and search, and renders the article as
  black-on-white with the cover image scaled to fit the page.
- [ ] Page emits Open Graph, Twitter Card, and JSON-LD
  `BlogPosting`/`Article` structured data using the frontmatter values
  (falling back to sensible defaults).
- [ ] Page is fully readable with JavaScript disabled.
- [ ] Page passes axe-core with zero serious or critical violations.

**Priority:** Must-have

### 5.3 Feature: Homepage with featured post and recent posts

**User story:** As a reader, I want the homepage to highlight the most
important article and show what's new so I can quickly find something to
read.

**Acceptance criteria:**

- [ ] Homepage hero/bio section displays Michael's photo, name, and a
  short tagline/bio.
- [ ] A "Featured" section appears above the recent-posts list and
  contains the **most recent non-draft post with `featured: true`**. If
  no such post exists, the section is omitted (not rendered as empty).
- [ ] Below the featured section, a "Recent posts" list shows up to **5**
  most recent non-draft posts in reverse chronological order, **excluding**
  the featured post.
- [ ] Each list item shows a thumbnail of the cover image, title (linked),
  publication date, and summary.
- [ ] A "View all posts" link goes to `/blog/`.

**Priority:** Must-have

### 5.4 Feature: Blog index, year index, and month index

**User story:** As a reader, I want to browse the archive by year and
month so I can find older posts.

**Acceptance criteria:**

- [ ] `/blog/` lists every year that contains at least one published
  post, in reverse chronological order, each linking to its year index.
- [ ] `/blog/{YYYY}/` lists the months in that year that contain
  published posts (linked to the month index) and lists every post from
  that year in reverse chronological order using the same summary card
  used on the homepage.
- [ ] `/blog/{YYYY}/{MM}/` lists every post from that month in reverse
  chronological order using the same summary card.
- [ ] Year and month pages are only generated for periods that contain at
  least one published post (no empty archive pages).
- [ ] Page titles and meta descriptions are unique per archive page for
  SEO.

**Technical notes:** Use Astro's `getStaticPaths()` driven from the
content collection.

**Priority:** Must-have

### 5.5 Feature: Site-wide navigation with brand and search

**User story:** As a reader on any page, I want consistent navigation and
search so I can move around the site quickly.

**Acceptance criteria:**

- [ ] A persistent header appears on every page containing: brand text
  "Michael F. Collins, III" linking to `/`, primary nav links to
  **About**, **Blog**, **Resume**, and a Pagefind search input.
- [ ] Search results render in a dropdown/panel attached to the input,
  keyboard-navigable (arrow keys, Enter to open, Esc to close).
- [ ] When JavaScript is disabled, the search input is replaced (or
  visually hidden with a fallback link) by a link to `/blog/` so
  navigation is never broken.
- [ ] Header collapses into a mobile-friendly menu (hamburger or
  equivalent) below the tablet breakpoint.
- [ ] Header includes a "Skip to main content" link as the first
  focusable element on every page.

**Priority:** Must-have

### 5.6 Feature: About page

**User story:** As a hiring manager, I want an About page so I can learn
who Michael is and what he does.

**Acceptance criteria:**

- [ ] Route `/about/` renders a long-form bio authored as a single
  Markdown/MDX file.
- [ ] Page includes a portrait photo with descriptive alt text.
- [ ] Page links to the Resume page and to all configured social
  profiles.

**Priority:** Must-have

### 5.7 Feature: Resume page with PDF download

**User story:** As a recruiter, I want to view Michael's resume in the
browser and download the PDF so I can share or archive it.

**Acceptance criteria:**

- [ ] Route `/resume/` renders an HTML version of the resume that is
  responsive and printable.
- [ ] A clearly labeled "Download PDF" button links to a PDF stored under
  `/public/` (e.g., `/michael-f-collins-iii-resume.pdf`) with
  `download` attribute and an accessible name including "PDF".
- [ ] The PDF link is also surfaced from the About page and footer.

**Priority:** Must-have

### 5.8 Feature: Social profile links in footer

**User story:** As a reader, I want to follow Michael on the platform I
already use.

**Acceptance criteria:**

- [ ] A site-wide footer renders icons (Font Awesome Pro brand icons) and
  accessible labels for the following profiles:
  - Email: `mailto:mfcollins3@me.com`
  - GitHub: `https://github.com/mfcollins3`
  - LinkedIn: `https://www.linkedin.com/in/michaelfcollins3/`
  - Medium: `https://medium.com/@mfcollins3`
  - YouTube: `https://www.youtube.com/@mfcollins3`
  - Facebook: `https://www.facebook.com/mfcollins3/`
  - Instagram: `https://www.instagram.com/mfcollins3/`
  - Threads: `https://www.threads.com/@mfcollins3`
  - Bluesky: `https://bsky.app/profile/mfcollins3.bsky.social`
  - X/Twitter: `https://x.com/mfcollins3`
  - TikTok: `https://www.tiktok.com/@mfcollins3`
- [ ] All external links open with `rel="noopener noreferrer"` and have
  visible accessible names (icon alone is not sufficient - include
  `aria-label` or visually hidden text).
- [ ] The email link uses `mailto:` and is labeled "Email".
- [ ] Profile URLs are configured in a single typed config file (e.g.,
  `src/config/social.ts`) so they can be updated in one place.

**Priority:** Must-have

### 5.9 Feature: Pagefind full-text search

**User story:** As a reader, I want to search blog posts by keyword so I
can find specific content quickly.

**Acceptance criteria:**

- [ ] Pagefind index is generated as a post-build step in CI and deployed
  alongside the static site.
- [ ] Only blog post pages are indexed (about, resume, archive indexes
  excluded via `data-pagefind-ignore` or include selectors).
- [ ] Search returns title, summary, publication date, and a snippet with
  the matched terms highlighted.
- [ ] Search UI in the header (per 5.5) is keyboard- and screen
  reader-accessible.

**Priority:** Must-have

### 5.10 Feature: Light / dark mode

**User story:** As a reader, I want the site to match my system color
scheme so it's comfortable to read.

**Acceptance criteria:**

- [ ] Site respects `prefers-color-scheme` on first paint with no FOUC.
- [ ] Light and dark themes both meet WCAG AA contrast for body text,
  links, and UI controls. The brand color `#87CEEB` is used only where
  contrast passes (e.g., as a hover/focus accent, large display
  headings, or paired with a darker variant for buttons).
- [ ] No manual theme toggle is required for v1.0.

**Priority:** Must-have

### 5.11 Feature: Responsive layout

**User story:** As a reader on any device, I want the site to look right
and be easy to use.

**Acceptance criteria:**

- [ ] Layout is verified at the following widths: 320, 375, 768, 1024,
  1440 px.
- [ ] No horizontal scrolling at any supported width.
- [ ] Tap targets are at least 44x44 CSS px on touch devices.
- [ ] Cover images use `srcset`/responsive sizes via Astro's image
  pipeline.

**Priority:** Must-have

### 5.12 Feature: SEO and syndication

**User story:** As Michael, I want strong SEO and syndication so my
content is discoverable and shareable.

**Acceptance criteria:**

- [ ] `sitemap.xml` is generated at build time and references all
  non-draft pages.
- [ ] `robots.txt` is published and references the sitemap.
- [ ] An RSS 2.0 feed at `/rss.xml` lists the most recent 20 published
  posts with title, link, publication date, summary, and author. The
  feed includes the summary + link only (not the full post body).
- [ ] An Atom feed alternative is acceptable but not required.
- [ ] Every page emits a unique `<title>`, `<meta name="description">`,
  canonical URL, Open Graph tags, and Twitter Card tags. Blog posts
  additionally emit JSON-LD `BlogPosting` structured data.
- [ ] A `humans.txt` is optional; not required.

**Priority:** Must-have

### 5.13 Feature: `llms.txt` and Markdown article artifacts

**User story:** As an LLM crawler, I want a structured index of the site
content and clean Markdown copies of each article so I can summarize
them accurately without parsing HTML.

**Acceptance criteria:**

- [ ] `/llms.txt` is generated at build time following the
  [llmstxt.org](https://llmstxt.org/) spec.
- [ ] File includes the site title, a short description, and grouped
  links to: About, Resume, Blog index, and each published blog post
  (title + summary + URL pointing at the `.md` artifact described
  below).
- [ ] For every published blog post, a Markdown artifact is emitted
  alongside the rendered HTML at the same path with a `.md`
  extension - i.e., the post at `/blog/{YYYY}/{MM}/{slug}/` is also
  reachable at `/blog/{YYYY}/{MM}/{slug}.md` (or
  `/blog/{YYYY}/{MM}/{slug}/index.md`, whichever the build pipeline
  supports cleanly).
- [ ] The `.md` artifact contains: a YAML frontmatter block with title,
  author, publication date, summary, canonical URL, and tags; followed
  by the original Markdown body of the post.
- [ ] The `.md` artifact is served with `Content-Type: text/markdown;
  charset=utf-8` (configured via GitHub Pages defaults or a
  build-emitted `_headers`-equivalent if needed; if GitHub Pages
  cannot set this MIME type, `text/plain` is acceptable as a
  fallback).
- [ ] An `Alternate` link tag (`<link rel="alternate" type="text/markdown"
  href="...">`) is emitted in the `<head>` of each HTML blog post
  pointing at its Markdown counterpart.
- [ ] Markdown artifacts are listed in `sitemap.xml` and excluded from
  Pagefind indexing (to avoid duplicate search hits).

**Technical notes:** Implement via an Astro endpoint
(`src/pages/blog/[year]/[month]/[slug].md.ts`) that imports the same
content collection entry and returns its raw `body` plus a serialized
frontmatter header. This keeps the `.md` and `.html` outputs in lockstep
from a single source of truth.

**Priority:** Should-have

### 5.14 Feature: iubenda consent + Google Analytics

**User story:** As a visitor, I want to control whether the site tracks
me, and as Michael, I want analytics once consent is granted.

**Acceptance criteria:**

- [ ] iubenda Cookie Solution is loaded on every page using site ID
  `37453753`.
- [ ] iubenda banner is rendered on first visit; choices are persisted
  per the iubenda default behavior.
- [ ] Google Analytics 4 (`gtag.js`) using Measurement ID
  `G-NDGMMHLHNR` is **not** loaded until the user grants consent for
  the analytics category. Revoking consent stops further events for
  the rest of the session.
- [ ] Privacy policy and cookie policy links (hosted by iubenda) appear
  in the site footer.
- [ ] No third-party requests other than iubenda fire on first paint.

**Priority:** Must-have

### 5.15 Feature: Print stylesheet for blog posts

**User story:** As a reader, I want to print an article cleanly so the
result is readable on paper.

**Acceptance criteria:**

- [ ] `@media print` CSS hides site header, footer, navigation, search,
  consent banner, and any decorative imagery beyond the cover.
- [ ] Body text prints in a serif or system font at 11-12pt with
  high-contrast black on white regardless of the active light/dark
  theme.
- [ ] Hyperlinks in printed output expose their URL (e.g., via
  `a::after { content: " (" attr(href) ")" }`) for footnote-style
  reading.

**Priority:** Must-have

### 5.16 Feature: GitHub Actions CI/CD to GitHub Pages

**User story:** As Michael, I want every merge to `main` to publish the
site automatically so I never have to deploy manually.

**Acceptance criteria:**

- [ ] A workflow under `.github/workflows/` runs on every push to `main`
  and on pull requests.
- [ ] On pull requests: install deps, run `astro check`, build, run
  Pagefind, run a Lighthouse-CI or axe smoke check (advisory, not
  blocking in v1.0).
- [ ] On `main`: build, run Pagefind, deploy to GitHub Pages using the
  official `actions/deploy-pages` action.
- [ ] The `michaelfcollins3.dev` custom domain is configured via a
  `CNAME` file generated into the build output, and HTTPS is enforced.
- [ ] Build fails (and deploy is skipped) if `astro check`, the build
  itself, or Pagefind generation fails.

**Priority:** Must-have

### 5.17 Feature: Terminal-browser and no-JS friendliness

**User story:** As a reader using `lynx`, `w3m`, or a TUI app, I want to
read articles without missing content.

**Acceptance criteria:**

- [ ] All primary content (homepage hero, post list, full post body,
  about, resume HTML, archive lists, footer links) is present in the
  initial server-rendered HTML.
- [ ] Pages use semantic landmarks (`<header>`, `<nav>`, `<main>`,
  `<article>`, `<footer>`).
- [ ] Site renders and is navigable in `lynx` against the local build
  output (verified manually before launch).

**Priority:** Should-have

### 5.18 Feature: Font Awesome Pro integration

**User story:** As Michael, I want to use my licensed Font Awesome Pro
icons consistently.

**Acceptance criteria:**

- [ ] The Font Awesome Pro downloadable kit is committed under
  `/public/fonts/fontawesome/` (or equivalent) and served as static
  assets from the same origin.
- [ ] The kit's CSS is included site-wide via a single `<link>` in the
  base layout.
- [ ] No third-party runtime fetches occur for icon assets (verified in
  the network panel).
- [ ] License terms are respected; the kit is not republished outside
  this site.

**Priority:** Must-have

## 6. Non-functional requirements

### 6.1 Performance

- Lighthouse Performance >= 95 on mobile for homepage and a representative
  blog post.
- LCP <= 2.0s on a simulated Moto G4 / Slow 4G connection.
- Total JS on any page <= 75 KB gzipped (excluding Pagefind's lazy-loaded
  index chunks).

### 6.2 Accessibility (WCAG 2.1 AA)

- Color contrast >= 4.5:1 for body text and >= 3:1 for large text and UI
  components in both light and dark themes.
- A brand color palette derived from `#87CEEB` must be defined as CSS
  custom properties before launch and used consistently:
  - `--brand-base: #87CEEB` - decorative use, dark-mode headings/links,
    large display text on dark backgrounds, illustration accents.
  - `--brand-strong` - a darker variant (target ~`#1E6A8C` or darker,
    final value to be confirmed by contrast testing) used for **all**
    light-mode interactive elements (links, buttons, focus rings)
    where it must achieve >= 4.5:1 against the page background.
  - `--brand-soft` (optional) - a lighter tint for hover backgrounds
    and section accents.
- The base `#87CEEB` is **never** used for body text or small UI text
  against a white background (contrast ~1.8:1, fails AA).
- Final palette values must be verified with a contrast tool (e.g.,
  WebAIM Contrast Checker) and the verified values recorded in the
  decisions log before launch.
- Every page has exactly one `<h1>`, a logical heading order, and a
  "Skip to main content" link as the first focusable element.
- All images require non-empty `alt` text in frontmatter unless they are
  decorative (in which case `alt=""` is explicit).
- All interactive elements are reachable and operable via keyboard with a
  clearly visible focus ring (do not rely on default browser focus
  alone).
- Forms / search input have associated `<label>` (visually hidden is
  acceptable).
- `<html lang="en">` set on every page.
- Respect `prefers-reduced-motion` for any animation introduced.
- ARIA used only where semantic HTML is insufficient.
- Verified pre-launch with: axe DevTools (zero serious/critical),
  Lighthouse Accessibility >= 95, manual keyboard pass, manual screen
  reader spot-check (VoiceOver on macOS).

### 6.3 Browser support

- **Tier 1 (fully supported)**: latest two stable versions of Chrome,
  Edge, Safari (macOS + iOS).
- **Tier 2 (best effort)**: latest stable Firefox.
- **Tier 3 (content must remain readable)**: `lynx`, `w3m`, `elinks`,
  `browsh`, and any HTTP client requesting raw HTML.

### 6.4 Error handling

- 404 page renders the site chrome and offers links to Home, Blog, and
  Search.
- Build-time errors (missing cover image, invalid frontmatter) fail the
  CI build with a clear message rather than producing a broken page.

### 6.5 Observability

- Google Analytics 4 (post-consent) for pageviews and outbound link
  clicks.
- GitHub Actions retains build logs for 30 days (default).
- No server-side logging is required (static hosting).

### 6.6 Security and privacy

- No secrets in the repo; Font Awesome npm token and any other
  credentials live in GitHub Actions secrets.
- All third-party scripts loaded with `defer` or `async` and from
  HTTPS origins only.
- A baseline Content Security Policy is published via `<meta>` allowing
  only the origins required (self, iubenda, Google Analytics, Google
  Tag Manager if used).
- Site is HTTPS-only; HTTP is redirected by GitHub Pages.

## 7. Open questions

- Final hero photo and About page portrait - do they exist or are they
  TBD?
- Bio/tagline text for the homepage hero - draft needed.
- Resume PDF source - is there a current version to ship at launch?
- Final value for `--brand-strong` (and optional `--brand-soft`) once
  contrast-tested in both light and dark themes.
- Google Search Console and Bing Webmaster Tools verification meta
  tags need to be added to `BaseLayout` once Michael completes the
  setup steps (see chat for setup instructions).

## 8. Decisions log

| Date       | Decision | Rationale | Made by |
|------------|----------|-----------|---------|
| 2026-04-24 | Use Astro with Markdown content collections, no CMS. | Static, owned content, fast to ship, no runtime cost. | Michael |
| 2026-04-24 | Host on GitHub Pages under the `mfcollins3` account with custom domain `michaelfcollins3.dev`. | Free, simple, integrates with GitHub Actions; domain already registered. | Michael |
| 2026-04-24 | Featured post chosen by manual `featured: true` flag, most recent wins, excluded from the recent-posts list. | Predictable editorial control without taxonomy complexity. | Michael |
| 2026-04-24 | URLs use `/blog/{YYYY}/{MM}/{slug}/`. | Stable, archive-friendly, supports year/month index pages. | Michael |
| 2026-04-24 | Brand color `#87CEEB` (sky blue), automatic light/dark per system, no manual toggle in v1.0. | Matches Michael's brand; reduces v1.0 scope. | Michael |
| 2026-04-24 | Defer tags, comments, share buttons, reading time, pagination, projects, and newsletter to v1.1+. | Hit the May 3, 2026 launch date. | Michael |
| 2026-04-24 | Google Analytics loads only after iubenda consent; iubenda site ID `37453753`, GA4 Measurement ID `G-NDGMMHLHNR`. | Privacy-respecting default; legal compliance. | Michael |
| 2026-04-24 | No per-PR preview environments in v1.0; local `astro dev` is the preview. | Keeps the May 3 launch achievable; GitHub Pages has no native PR previews. | Michael |
| 2026-04-24 | Brand palette derived from `#87CEEB`: base for decorative/dark-mode use, a darker `--brand-strong` variant for light-mode interactive elements. | `#87CEEB` fails WCAG AA on white for text/UI; a paired darker shade is required for accessibility. | Michael |
| 2026-04-24 | Font Awesome Pro served via the downloadable Pro kit, self-hosted from `/public/`. | Avoids npm token management and runtime CDN fetches; simplest setup. | Michael |
| 2026-04-24 | Emit a `.md` artifact for every blog post co-located with its `.html` output, referenced by `llms.txt` and `<link rel="alternate">`. | Gives LLMs a clean, parseable copy from the same source of truth. | Michael |
| 2026-04-24 | RSS feed includes summary + link only (not full post body). | Keeps the feed lightweight; drives readers to the site for full content. | Michael |
| 2026-04-24 | Pagefind for search, generated as a post-build step in CI. | Static, zero-backend, works on GitHub Pages. | Michael |
| 2026-04-24 | Font Awesome Pro via licensed npm package, no kit script. | Subsetted, no third-party runtime fetch, works offline. | Michael |
| 2026-04-24 | Generate `llms.txt` per llmstxt.org. | Improves LLM-driven discovery and summarization. | Michael |
