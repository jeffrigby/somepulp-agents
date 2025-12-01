---
description: Research a library, framework, or technical topic
arguments:
  - name: topic
    description: The library, framework, API, or technical topic to research
    type: string
    required: true
---

Use the research-assistant agent to research the specified topic.

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
