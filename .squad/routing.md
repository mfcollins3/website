# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Scope, ADRs, architecture | Mal | "should this be in v1.0?", new ADR, PR review on structural changes |
| Astro components, layouts, CSS | Kaylee | New page, layout tweak, component, responsive fix |
| Accessibility (WCAG, a11y, lynx, no-JS) | Kaylee | Keyboard nav, contrast, semantic HTML, screen reader pass |
| Content collections, frontmatter, MDX | Book | New post type, schema change, tag/taxonomy work |
| SEO, RSS, sitemap, llms.txt, OG/JSON-LD | Book | Feed work, meta tags, structured data |
| Pagefind config and indexing | Book | Search config and index tuning (UI lives with Kaylee) |
| GitHub Actions, build, deploy, Pages, DNS | Wash | New workflow, deploy fix, custom domain, Lighthouse CI |
| Code review | Mal | Review PRs, defend the v1.0 cut line |
| Scope & priorities | Mal | What's in v1.0, trade-offs, ship-by-May-3 calls |
| Session logging | Scribe | Automatic — never needs routing |
| Work queue / backlog monitor | Ralph | "Ralph, go", "what's on the board?" |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:{member}` label | Lead |
| `squad:{name}` | Pick up issue and complete the work | Named member |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. The Lead handles all `squad` (base label) triage.
