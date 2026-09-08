---
name: official-docs
description: Fetch official documentation and code examples for a library or API from authoritative sources only — Context7, official docs sites, official GitHub repos. Never blogs or forums.
when_to_use: When the user says "get the docs for", "fetch official docs", "look up the documentation", or needs authoritative reference material before implementing something.
argument-hint: "<topic>"
context: fork
agent: official-docs
---

Fetch official documentation for the following topic.

IMPORTANT RULES:
1. Only use official sources (Context7, official docs sites, official GitHub repos)
2. Never use blogs, Stack Overflow, tutorials, or community content
3. Be explicit about what you found AND what you couldn't find
4. If no official docs exist, say so clearly

Provide:
- Overview from official source
- Quick start / installation
- Key APIs or patterns relevant to the topic
- Code example from official repo or docs
- Links to official sources
- Clear statement of what wasn't found (if applicable)

Topic: $ARGUMENTS
