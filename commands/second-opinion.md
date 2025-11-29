---
description: Get a second opinion from Codex or Gemini on code or architecture
arguments:
  - name: request
    description: The code, architecture decision, or technical question to get a second opinion on
    type: string
    required: true
---

Get a second opinion from an external AI assistant on the specified code, architecture decision, or technical question.

Available consultants:
- **Codex** (OpenAI) - Use the codex-consultant agent
- **Gemini** (Google) - Use the gemini-consultant agent

Consultation types:
- Code review / quality check
- Architecture / design opinion
- Debugging / root cause analysis
- Security audit
- Performance review

All consultations run in read-only/sandbox mode for safety.

Request: $ARGUMENTS
