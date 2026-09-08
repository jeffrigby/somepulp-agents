---
name: research
description: Research a library, framework, API, or technical topic using official documentation, GitHub code examples, and web sources.
when_to_use: When the user asks to "research", "investigate", "compare", or "learn about" a library, framework, or technical concept.
argument-hint: "<topic>"
context: fork
agent: research-assistant
---

Research the following topic thoroughly.

Prioritize:
1. Context7 for official documentation
2. GitHub CLI for code examples and repository information
3. Web search for additional context

Provide:
- Summary of key findings
- Installation and setup guidance (if applicable)
- Best practices and common patterns
- Code examples from official sources
- Links to authoritative documentation

Research topic: $ARGUMENTS
