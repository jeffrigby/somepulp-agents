# AI Consultation Decision Tree

This guide helps determine the right type of consultation, safety mode, and approach based on the user's request.

## Primary Decision Tree

```
User Request -> What is the consultation goal?
    |
    |-- CODE REVIEW / QUALITY CHECK
    |   |-- Mode: Read-only/Sandbox
    |   |-- Focus: Quality, security, best practices
    |   +-- See: "Code Review Path" below
    |
    |-- ARCHITECTURE / DESIGN OPINION
    |   |-- Mode: Read-only/Sandbox
    |   |-- Focus: Structure, patterns, scalability
    |   +-- See: "Architecture Path" below
    |
    |-- DEBUGGING / ROOT CAUSE ANALYSIS
    |   |-- Mode: Read-only/Sandbox
    |   |-- Focus: Finding causes, suggesting fixes
    |   +-- See: "Debugging Path" below
    |
    |-- REFACTORING / IMPLEMENTATION CHANGES
    |   |-- Mode: CAUTION - requires confirmation
    |   |-- Focus: Making actual changes
    |   +-- See: "Implementation Path" below
    |
    +-- GENERAL CONSULTATION / SECOND OPINION
        |-- Mode: Read-only/Sandbox
        |-- Focus: Alternative perspective
        +-- See: "General Consultation Path" below
```

## Code Review Path

### When to Use
- User asks for "code review"
- User wants security audit
- User asks "is this code good?"
- User wants best practices check
- User mentions quality concerns

### Decision Points

```
Code Review -> What aspect to focus on?
    |
    |-- COMPREHENSIVE REVIEW
    |   +-- Analyze: quality + security + performance + maintainability
    |       Template: "Comprehensive Code Review"
    |
    |-- SECURITY FOCUSED
    |   +-- Analyze: vulnerabilities, OWASP, authentication, authorization
    |       Template: "Security Audit"
    |
    |-- PERFORMANCE FOCUSED
    |   +-- Analyze: algorithms, bottlenecks, optimization opportunities
    |       Template: "Performance Review"
    |
    +-- SPECIFIC CONCERN
        +-- Analyze: user-specified issue
            Template: Custom prompt based on concern
```

## Architecture Path

### When to Use
- User asks "what do you think of this architecture?"
- User wants design opinion
- User asks "how should I design this?"
- User mentions system structure
- User asks about scalability

### Decision Points

```
Architecture -> What type of architectural question?
    |
    |-- OVERALL DESIGN REVIEW
    |   +-- Analyze: structure, separation of concerns, patterns used
    |       Template: "Architecture Review"
    |
    |-- SCALABILITY ASSESSMENT
    |   +-- Analyze: scaling bottlenecks, distributed system concerns
    |       Template: "Scalability Analysis"
    |
    |-- PATTERN RECOMMENDATION
    |   +-- Analyze: current approach, suggest appropriate patterns
    |       Template: "Design Pattern Consultation"
    |
    +-- TECHNOLOGY CHOICE
        +-- Analyze: options, tradeoffs, recommendation
            Template: "Technology Decision"
```

## Debugging Path

### When to Use
- User describes a bug or issue
- User asks "why is this failing?"
- User wants diagnostic help
- User asks "what's causing this?"
- User mentions intermittent problems

### Decision Points

```
Debugging -> What type of investigation?
    |
    |-- ROOT CAUSE ANALYSIS
    |   +-- Analyze: code flow, potential failure points, likely causes
    |       Template: "Root Cause Analysis"
    |
    |-- INTERMITTENT ISSUE
    |   +-- Analyze: race conditions, timing issues, state problems
    |       Template: "Intermittent Bug Analysis"
    |
    |-- PERFORMANCE PROBLEM
    |   +-- Analyze: bottlenecks, inefficient algorithms, resource usage
    |       Template: "Performance Investigation"
    |
    +-- UNEXPECTED BEHAVIOR
        +-- Analyze: logic errors, edge cases, assumptions
            Template: "Behavior Analysis"
```

## Implementation Path

### When to Use
- User asks AI to "fix this"
- User wants actual code changes
- User asks for refactoring implementation
- User wants AI to "make changes"

### IMPORTANT: Always Confirm First

```
Implementation Request -> Get user confirmation
    |
    |-- User confirms changes -> Proceed with write mode
    |   +-- Configure for safe modification
    |
    +-- User wants analysis only -> Switch to read-only consultation
        +-- Provide suggestions without making changes
```

## General Consultation Path

### When to Use
- User asks "what would the AI think?"
- User wants second opinion
- User asks for alternative perspective
- Generic consultation request

### Decision Points

```
General Consultation -> Clarify the specific need
    |
    |-- Clarification reveals specific type
    |   +-- Route to appropriate path above
    |
    +-- Truly general second opinion
        |-- Mode: Read-only/Sandbox
        +-- Prompt: Open-ended analysis request
```

## Special Cases

### Case 1: User Uncertainty About What They Need

```
Unclear Request -> Ask clarifying questions
    |
    +-- Examples:
        "Do you want a code review, architecture opinion, or debugging help?"
        "Should I ask the AI to analyze the code or make changes?"
        "Are you looking for security review, performance analysis, or general quality check?"
```

### Case 2: Multiple Consultation Types Needed

```
Multiple Needs -> Prioritize and sequence
    |
    +-- Approach:
        1. Start with read-only analysis
        2. Present findings
        3. If changes needed, confirm and proceed

Example:
    "First, let me get the AI's code review..."
    [After review]
    "The AI suggests refactoring. Would you like to proceed with those changes?"
```

### Case 3: Very Large Codebase

```
Large Codebase -> Be specific
    |
    +-- Instead of: "Review the entire codebase"
        Use: "Review src/auth/login.js for security issues"

        Break into smaller consultations:
        1. Review critical modules first
        2. Get targeted analysis
        3. Combine insights
```

## Safety Mode Quick Reference

| User Request Type | Safety Mode | Rationale |
|-------------------|-------------|-----------|
| Code review | Read-only | Safe analysis, no changes |
| Security audit | Read-only | Analysis only |
| Architecture opinion | Read-only | Evaluation, not modification |
| Debugging analysis | Read-only | Investigation, not fixes |
| Performance review | Read-only | Analysis first, changes later |
| Second opinion | Read-only | Consultation, not implementation |
| "Fix this" | CONFIRM FIRST | Requires user approval |
| "Refactor this" | CONFIRM FIRST | Requires user approval |
| "Implement feature" | CONFIRM FIRST | Requires user approval |

## Common User Phrases -> Consultation Type Mapping

| User Says | Consultation Type | Mode |
|-----------|------------------|------|
| "Review this code" | Code Review | Read-only |
| "What do you think of this?" | General -> Clarify | Read-only |
| "Is this secure?" | Security Audit | Read-only |
| "Why is this slow?" | Performance Debug | Read-only |
| "How should I architect this?" | Architecture Opinion | Read-only |
| "Fix this bug" | Implementation | CONFIRM FIRST |
| "Refactor this" | Implementation | CONFIRM FIRST |
| "What would the AI do?" | General Consultation | Read-only |
| "Second opinion?" | General -> Clarify | Read-only |
| "Can you debug this?" | Debugging Analysis | Read-only |

## Summary Flow

```
1. Identify consultation type from user request
   |
2. Determine safety mode (default: read-only)
   |
3. If write mode needed: CONFIRM WITH USER FIRST
   |
4. Prepare specific prompt (see prompt-templates.md)
   |
5. Execute with appropriate configuration
   |
6. Process results critically
   |
7. Present synthesized insights to user
```
