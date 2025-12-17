---
description: Get a second opinion from Google Gemini on code or architecture
arguments:
  - name: request
    description: The code, architecture decision, or technical question to get a second opinion on
    type: string
    required: true
---

Use the gemini-consultant agent to get a second opinion from Google Gemini on the specified code, architecture decision, or technical question.

Consultation types:
- Code review / quality check
- Architecture / design opinion
- Debugging / root cause analysis
- Security audit
- Performance review

All consultations run in read-only/sandbox mode for safety.

Request: $ARGUMENTS
