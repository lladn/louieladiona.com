---
date: '2026-04-24T02:20:51-07:00'
title: 'Personal Page with Hugo'
draft: false
showtoc: true
tocopen: false
tags: ['hugo', 'website', 'ssg', 'static site']
---


Creating my personal site (the one you’re reading right now). I used a static site generator called Hugo. I picked it mainly because I’m already a bit familiar with Go, but the nice thing is you don’t actually need to know Go at all to use it. It’s simple, fast, and gets out of your way. In this post, I just want to walk through how I got started and how I began building my own documentation space.

## Getting Started with Hugo

First things first: [installation](https://gohugo.io/installation/). Hugo has solid documentation that covers different environments, so it’s best to follow their official installation guide depending on your setup.

Once installed, I’d strongly recommend going through their “Getting Started” section. It gives you a clear idea of how everything fits together.

To create a new site, just run:

```sh
hugo new site <name>
```

Hugo immediately gives you helpful next steps, which is a nice touch. After that:

```sh
cd <name>
```

## Choosing a Theme

This part honestly took me the longest. There are hundreds of themes available, and picking one isn’t exactly straightforward. I wish there were better filters, but I eventually realized they’re roughly sorted by GitHub stars.

That led me to the PaperMod theme. It checked all the boxes for me: clean, minimal, blog-friendly, and with dark mode support. The documentation also looked solid, which made the decision easier.

If you want to in dept features of [PaperMod](https://github.com/adityatelange/hugo-PaperMod/wiki/Features)

To set it up, I initialized a Git repository:

```sh
git init
```

Then added the theme as a submodule:

```sh
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
```

## Configuring the Site

Hugo uses a configuration file, typically `hugo.toml`. I switched mine to YAML since I’m more comfortable with it.

Here’s a simple starting point:

```yaml
baseURL: ""
languageCode: en-us
title: Your Name
theme: PaperMod
```

Once that’s in place, you can spin up your site locally:

```sh
hugo server -D
```

The `-D` flag includes draft content, and Hugo’s live reload makes development really smooth. Just keep the server running while you work.

## Creating Content

Adding content is straightforward:

```sh
hugo new content posts/my-first-post.md
```

This creates a Markdown file inside the `content` folder. Hugo also generates some default metadata at the top:

```toml
+++
title = 'My First Post'
date = 2023-11-12T22:40:04+02:00
draft = true
+++
```

You can edit the title and start writing your content right below it. Save the file, and you’ll instantly see it reflected on your local site.

If you prefer YAML over TOML (like I do), you can tweak the archetype template in the `archetypes` folder.

## Adding a Menu

To add a simple navigation menu, update your config file:

```yaml
menu:
  main:
    - identifier: posts
      name: Posts
      url: /posts/
      weight: 10
    - identifier: tags
      name: Tags
      url: /tags/
      weight: 20
    - identifier: search
      name: Search
      url: /search/
      weight: 30
```

You can also tag your posts by adding something like:

```yaml
tags: ['tag1', 'tag2']
```

Then just navigate to the tags page to see them in action.

One small quirk I noticed: sometimes the site doesn’t reload properly. Saving the config file usually fixes it.

## Adding Search

The search page doesn’t exist by default, so you’ll need to create it:

```sh
hugo new content search.md
```

Then update its metadata:

```yaml
---
title: "Search"
layout: "search"
summary: "search"
placeholder: "start typing here ..."
---
```

## Customizing the Homepage

To add a bit of personality to the homepage, you can include an intro and social links:

```yaml
params:
  homeInfoParams:
    title: Some fancy text...
    Content: This is my personal blog...
  socialIcons:
    - name: github
      url: "https://github.com/username"
    - name: linkedin
      url: "https://linkedin.com/in/username"
```

Just swap in your own links and text.


## Adding comment system
Adding comments is straightforward since PaperMod supports it out of the box — you just need to wire up an external provider. Disqus is a popular option but it's paid and comes bundled with ads, so I skipped it. Instead, I went with giscus, which is free and backed by GitHub Discussions. The only caveat is that readers need a GitHub account to comment, but since this blog leans technical, that's a reasonable assumption.
To set it up, create a layouts/partials/comments.html file in your Hugo project and paste in the script snippet generated from the giscus website. Then enable it in your hugo.yaml (or hugo.toml) under params:

```json
params:
  comments: true
```

The giscus will generate like this. 
```html
<script src="https://giscus.app/client.js"
  data-repo="lladn/your-repo"
  data-repo-id="YOUR_REPO_ID"
  data-category="General"
  data-category-id="YOUR_CATEGORY_ID"
  data-mapping="pathname"
  data-strict="0"
  data-reactions-enabled="1"
  data-emit-metadata="0"
  data-input-position="bottom"
  data-theme="preferred_color_scheme"
  data-lang="en"
  crossorigin="anonymous"
  async>
</script>
```


## Final Thoughts

At this point, things already start to look pretty good.

What I really like about Hugo is how everything is file-based and content is just Markdown. It keeps things simple and flexible. And if you ever want to tweak something, you can dive into the HTML, CSS, or JavaScript and make it your own.

If you want to go deeper, the documentation is extensive and well-written. There’s a lot you can do once you get comfortable with the basics.
