---
title: A GitHub Action for Importing Blue Sky RSS Feeds
date: 2025-03-12
cover_attribution: >
    Photo by <a href="https://unsplash.com/@timmossholder?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Tim Mossholder</a> on <a href="https://unsplash.com/photos/cogs-and-gears-GmvH5v9l3K4?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
description: >
    I look at creating a custom GitHub Action in this article. The action that I wrote imported a Blue Sky RSS feed and fixed timestamp formatting issues so that my static website generator could read the feed and syndicate the posts on my website.
summary: >
    When building my new website, I wanted to bring in my most recent Blue Sky posts to also attract new readers to follow me on Blue Sky. I ran into an interesting problem though. My website generator couldn't read timestamps in the format that BlueSky published them. In this article, I walk through what I want to do, the problem that I hit, and my first exploration into building a custom GitHub Action to solve the problem and get my Blue Sky posts on my website.
---
## The Problem
My website is a static website, meaning that there is no application behind it. When I publish my website, it's just a set of HTML files, CSS, a little JavaScript, and images and other assets. The files are served from an HTTP server. I'm hosting my website using [GitHub Pages](https://pages.github.com/), so I am assuming that there's some sort of content delivery network with edge locations around the world where my website is cached and served from.

I generate my website using [Hugo](https://gohugo.io). Hugo is a static website generator written in Go that has a lot of great features for content management and templating. And Hugo is very fast when generating static websites.

One feature that I wanted in my new website was the ability to have a section on the homepage where I could show posts that I am making to [Blue Sky](https://bluesky.app). Blue Sky is my new microblogging site since Twitter/X turned into a cesspool. And if you're interested in following me on Blue Sky, check out [my profile](https://bsky.app/profile/mfcollins3.bsky.social).

Hugo has the ability to load external data and use that data to generate HTML content. And Blue Sky has the ability to generate RSS feeds containing user posts. I ran into a problem though in that Hugo has limitations on the format that it supports for timestamps in data and Blue Sky doesn't output the RSS `<pubDate>` field in a format that Hugo supports. So to add my Blue Sky posts to my website, I had to go a different route.

For example, here is a sample of the RSS feed from my Blue Sky profile as of when I wrote this article:

{{< highlight xml >}}
<rss version="2.0">
    <channel>
        <description>I am a professional software developer and I love to cook. I work for Neudesic and am a Senior Director for Application Innovation in the Desert market (Phoenix and Las Vegas). I am currently based in the Phoenix metro area and live in Surprise, Arizona.</description>
        <link>https://bsky.app/profile/mfcollins3.bsky.social</link>
        <title>@mfcollins3.bsky.social - Michael F. Collins, III</title>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3lk5r4x75cs2t</link>
            <description>I've been listening to the audiobook of The City of Mirrors again on Audible. I desperately need movies done of this book trilogy. It's so unfortunate that Fox messed up The Passage and the series was cancelled after the first season. I just want to see "the seige" happen on the big screen.</description>
            <pubDate>12 Mar 2025 04:38 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3lk5r4x75cs2t</guid>
        </item>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3lk5qiymcbk2t</link>
            <description>Just published: a new article about fair-code and software licensing. This is a look at how I might be able to start building products openly, sharing the source code for others to see, while protecting rights to earn income from my software products: https://michaelfcollins3.dev/blog/2025/03/fair-use-licensing/</description>
            <pubDate>12 Mar 2025 04:27 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3lk5qiymcbk2t</guid>
        </item>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3ljyssrxgms2l</link>
            <description>2025 has been a year of setting and achieving goals, no matter how difficult they are. So far I've attacked my caffeine addition and have been "sober" for over 60 days now. I'm back in the gym and working to rebuild me. I'm also setting aside an hour each day for "me" time to read and learn.</description>
            <pubDate>10 Mar 2025 05:24 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3ljyssrxgms2l</guid>
        </item>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3ljysgjilss2l</link>
            <description>After a long hiatus, I'm back with a new website and blog trying to share my thoughts and ideas around software development. Here's my first post reintroducing development containers and what you can do with them: https://michaelfcollins3.dev/blog/2025/03/development-containers/</description>
            <pubDate>10 Mar 2025 05:18 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3ljysgjilss2l</guid>
        </item>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3lcrjwpsahk2t</link>
            <description>You know when you spend all day building something great and everything is clicking, but your program isn’t working right and you’re getting frustrated and then you take a break to go to dinner and come home and read the documentation and then you change your code to do it the right way?</description>
            <pubDate>08 Dec 2024 06:01 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3lcrjwpsahk2t</guid>
        </item>
        <item>
            <link>https://bsky.app/profile/mfcollins3.bsky.social/post/3lbocp57wks2e</link>
            <description>I built my biggest dev container to date: Prometheus, Grafana, Dapr services, Redis, RabbitMQ, Azurite, SQL Server, Cosmos DB emulator, OpenZipkin, APISIX, Traefik, and ngrok. It’s almost the ultimate dev container for local Azure development!</description>
            <pubDate>24 Nov 2024 05:48 +0000</pubDate>
            <guid isPermaLink="false">at://did:plc:ukyfcg7nrk44w2wqpj2afjl5/app.bsky.feed.post/3lbocp57wks2e</guid>
        </item>
    </channel>
</rss>
{{< /highlight >}}

Blue Sky outputs the `<pubDate>` element with a timestamp in the format `24 Nov 2024 05:48 +0000`. The issue is that Hugo doesn't recognize that format even though it's valid. Hugo needs the seconds in the timestamp and won't accept it without. I could attempt to create an issue in Hugo's GitHub repository or fix it myself, but that would take time and may or may not get approved. Or I could look to fix it some other way on my own to rewrite the timestamp so that Hugo will be able to parse the RSS feed.

I use [GitHub Actions](https://github.com/features/actions) to build and publish my website to GitHub Pages. Using GitHub Actions, I had two options:

1. Figure out how to use a shell script or call a small custom program that could import the RSS feed from Blue Sky and rewrite it for Hugo,
2. Create a reusable GitHub Action that I and others can use to import the RSS feed from Blue Sky and rewrite it for Hugo.

I had limited experience in writing custom GitHub Actions, but this sounded like a great opportunity to get in there and do it, so I chose #2. The rest of this post explains how I built my custom GitHub Action and what I learned along the way.

## The Solution

A custom GitHub Action begins with a file named `action.yaml`. This file is stored in the root directory of the GitHub repository containing the custom action. `action.yaml` contains metadata about the GitHub Action including a list of inputs that are sent to the GitHub Action at runtime, outputs produced by the GitHub Action, and information on how to run the GitHub Action. GitHub Actions can be written either using JavaScript or as a Docker container. At the time, I didn't want to spend the time figuring out how to do this in JavaScript, so I opted to write my custom action in Go and deploy it as a Docker container instead.

Here's my [`action.yaml`](https://github.com/mfcollins3/hugoify-bluesky-rss-feed/blob/main/action.yaml) file:

{{< highlight yaml >}}
name: Hugoify Blue Sky RSS Feed
author: Michael F. Collins, III
description: Downloads an RSS feed from Blue Sky and formats the RSS for Hugo to use.
inputs:
  url:
    description: The URL of the Blue Sky RSS feed to download.
    required: true
  path:
    description: The path to save the re-formatted RSS feed.
    required: true
runs:
  using: docker
  image: Dockerfile
{{< /highlight >}}

My custom GitHub Action will has two inputs:

- `url`: the URL for where the RSS feed can be found and downloaded from.
- `path`: the output path where the patched RSS feed will be written to.

In my GitHub Actions workflow, I can specify these values:

{{< highlight yaml >}}
- name: Download and Format the Blue Sky RSS Feed
  uses: mfcollins3/hugoify-bluesky-rss-feed@main
  with:
    url: https://bsky.app/profile/mfcollins3.bsky.social/rss
    path: content/bluesky_rss.xml
{{< /highlight >}}

When my GitHub Action is executed, the parameters are passed to my action using environment variables with an `INPUT_` prefix:

- `INPUT_URL`
- `INPUT_PATH`

The first thing that I did in Go was to model the RSS feed structure for parsing and generating the RSS XML:

{{< highlight go >}}
type rss struct {
	XMLName xml.Name `xml:"rss"`
	Version string   `xml:"version,attr"`
	Channel channel  `xml:"channel"`
}

type channel struct {
	Description string `xml:"description"`
	Link        string `xml:"link"`
	Title       string `xml:"title"`
	Items       []item `xml:"item"`
}

type item struct {
	Link        string `xml:"link"`
	Description string `xml:"description"`
	PubDate     string `xml:"pubDate"`
	Guid        guid   `xml:"guid"`
}

type guid struct {
	IsPermaLink string `xml:"isPermaLink,attr"`
	Value       string `xml:",chardata"`
}
{{< /highlight >}}

Next, I read the environment variables to get the download URL and the output path:

{{< highlight go >}}
url, ok := os.LookupEnv("INPUT_URL")
if !ok {
    log.Fatal("The url input is required.")
}

path, ok := os.LookupEnv("INPUT_PATH")
if !ok {
    log.Fatal("The path input is required.")
}
{{< /highlight >}}

Next, I downloaded the RSS feed from Blue Sky and parsed the RSS XML document:

{{< highlight go >}}
resp, err := http.Get(url)
if err != nil {
    log.Fatalf("Failed to download the RSS feed: %v", err)
}

defer func() {
    _ = resp.Body.Close()
}()

if resp.StatusCode != http.StatusOK {
    log.Fatalf(
        "Failed to download RSS feed. Status code: %d",
        resp.StatusCode,
    )
}

var rss rss
decoder := xml.NewDecoder(resp.Body)
if err = decoder.Decode(&rss); err != nil {
    log.Fatalf("Failed to parse the RSS feed: %v", err)
}
{{< /highlight >}}

Now that I had the RSS feed data, I can loop through the feed items to parse and patch the `<pubDate>` timestamp with a format that Hugo will understand:

{{< highlight go >}}
for i := range rss.Channel.Items {
    pubDate, err := time.Parse(
        "02 Jan 2006 15:04 -0700",
        rss.Channel.Items[i].PubDate,
    )
    if err != nil {
        log.Fatalf("Failed to parse the pubDate field: %v", err)
    }

    rss.Channel.Items[i].PubDate = pubDate.Format(
        "2006-01-02T15:04:05-07:00",
    )
}
{{< /highlight >}}

Line 2 uses the `time.Parse` function to parse the timestamp generated by Blue Sky which is in the format `02 Jan 2006 15:04 -0700`. I'm reformatting the timestamp on line 10 using a standard Internet format that Hugo does support in the format `yyyy-mm-ddThh:mm:ss<time offset>`.

Finally, I'm writing the patched RSS feed back out as XML:

{{< highlight go >}}
file, err := os.Create(path)
if err != nil {
    log.Fatalf("Failed to create the file: %v", err)
}

defer func() {
    _ = file.Close()
}()

encoder := xml.NewEncoder(file)
encoder.Indent("", "  ")
if err = encoder.Encode(rss); err != nil {
    log.Fatalf("Failed to write the RSS feed: %v", err)
}
{{< /highlight >}}

Here's the entire source code for my custom GitHub Action:

{{< highlight go >}}
package main

import (
	"encoding/xml"
	"log"
	"net/http"
	"os"
	"time"
)

type rss struct {
	XMLName xml.Name `xml:"rss"`
	Version string   `xml:"version,attr"`
	Channel channel  `xml:"channel"`
}

type channel struct {
	Description string `xml:"description"`
	Link        string `xml:"link"`
	Title       string `xml:"title"`
	Items       []item `xml:"item"`
}

type item struct {
	Link        string `xml:"link"`
	Description string `xml:"description"`
	PubDate     string `xml:"pubDate"`
	Guid        guid   `xml:"guid"`
}

type guid struct {
	IsPermaLink string `xml:"isPermaLink,attr"`
	Value       string `xml:",chardata"`
}

func main() {
	url, ok := os.LookupEnv("INPUT_URL")
	if !ok {
		log.Fatal("The url input is required.")
	}

	path, ok := os.LookupEnv("INPUT_PATH")
	if !ok {
		log.Fatal("The path input is required.")
	}

	resp, err := http.Get(url)
	if err != nil {
		log.Fatalf("Failed to download the RSS feed: %v", err)
	}

	defer func() {
		_ = resp.Body.Close()
	}()

	if resp.StatusCode != http.StatusOK {
		log.Fatalf(
			"Failed to download RSS feed. Status code: %d",
			resp.StatusCode,
		)
	}

	var rss rss
	decoder := xml.NewDecoder(resp.Body)
	if err = decoder.Decode(&rss); err != nil {
		log.Fatalf("Failed to parse the RSS feed: %v", err)
	}

	for i := range rss.Channel.Items {
		pubDate, err := time.Parse(
			"02 Jan 2006 15:04 -0700",
			rss.Channel.Items[i].PubDate,
		)
		if err != nil {
			log.Fatalf("Failed to parse the pubDate field: %v", err)
		}

		rss.Channel.Items[i].PubDate = pubDate.Format(
			"2006-01-02T15:04:05-07:00",
		)
	}

	file, err := os.Create(path)
	if err != nil {
		log.Fatalf("Failed to create the file: %v", err)
	}

	defer func() {
		_ = file.Close()
	}()

	encoder := xml.NewEncoder(file)
	encoder.Indent("", "  ")
	if err = encoder.Encode(rss); err != nil {
		log.Fatalf("Failed to write the RSS feed: %v", err)
	}
}
{{< /highlight >}}

Finally, I needed to package this up as a Docker container. Here's my `Dockerfile`:

{{< highlight docker >}}
FROM golang:1.24.0-bookworm AS build

WORKDIR /go/src/github.com/mfcollins3/hugoify-bluesky-rss-feed
COPY . .
RUN CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    go build -v -o /opt/blueskyrss/bin/blueskyrss ./cmd/blueskyrss/main.go

FROM alpine:3.21.3

WORKDIR /opt/blueskyrss

COPY --from=build /opt/blueskyrss/bin/blueskyrss bin/

ENTRYPOINT ["/opt/blueskyrss/bin/blueskyrss"]
{{< /highlight >}}

This `Dockerfile` uses a multi-stage build to create one container that will compile my program using the Go compiler. The second container is then created based on Alpine Linux to run my program.

## Take-aways

My first take-away from this process is that writing a custom GitHub Action was not as difficult as I first thought it was. Once I got over the learning hurdle to figure out how to get my input parameters, the rest of the process was pretty straightforward. I was able to test out my program, then publish the source code to the GitHub repo, and then consume my custom GitHub Action in my website's workflow without any issues. And the end result was that I was able to get my Blue Sky posts on my website homepage.

The one downside is related to performance. The way that I packaged my GitHub Action, every time it is consumed in a workflow the Docker container needs to be built. On average, that takes about 20-25 seconds of build time. I can address this by taking another step and publishing the Docker container to [GitHub Packages](https://docs.github.com/en/packages). It might also be more performant to rewrite the GitHub Action to use JavaScript instead. But this is working, so I'll leave exploring those for another blog post.

You can find the source code for my GitHub Action in the [`mfcollins3/hugoify-bluesky-rss-feed`](https://github.com/mfcollins3/hugoify-bluesky-rss-feed) repository here. You can see it in action by looking at my [website repository](https://github.com/mfcollins3/website).