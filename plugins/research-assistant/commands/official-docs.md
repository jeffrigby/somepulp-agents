---
description: Fetch official documentation and code examples before starting a task
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
