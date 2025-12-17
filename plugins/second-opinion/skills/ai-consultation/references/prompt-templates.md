# AI Consultation Prompt Templates

This document provides ready-to-use prompt templates for different types of AI consultations. Customize the placeholders (marked with [BRACKETS]) for your specific needs.

## Code Review Templates

### Comprehensive Code Review
```
Perform a comprehensive code review of [FILE/MODULE]. Focus on:
1. Code quality and maintainability
2. Error handling and edge cases
3. Security vulnerabilities
4. Performance considerations
5. Best practices and design patterns
6. Documentation completeness

Provide specific line numbers and actionable suggestions for each issue found.
Rate issues by severity: Critical/High/Medium/Low.
```

### Security Audit
```
Perform a security audit of [FILE/MODULE]. Check for:
- Authentication and authorization issues
- Input validation and sanitization
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) risks
- CSRF protection
- Sensitive data exposure
- Session management security
- Rate limiting and DoS protection
- Dependency vulnerabilities

For each finding:
- Provide line numbers
- Rate severity (Critical/High/Medium/Low)
- Explain the vulnerability
- Suggest remediation steps
```

### Performance Review
```
Analyze [FILE/MODULE] for performance issues. Look for:
- Inefficient algorithms (O(n²) or worse)
- Unnecessary synchronous operations
- Memory leaks
- Excessive object creation
- Database query inefficiencies (N+1 queries, missing indexes)
- Missing caching opportunities
- Blocking I/O operations
- Large file handling issues

For each issue:
- Provide line numbers
- Estimate performance impact
- Suggest specific optimizations
- Recommend profiling approaches
```

### Error Handling Review
```
Analyze error handling in [FILE/MODULE]. Check:
- Consistency of error handling patterns
- Appropriate use of try/catch blocks
- Error logging completeness
- User-facing error messages (clarity, security)
- Error recovery strategies
- Unhandled promise rejections
- Global error handlers
- Error propagation approach

Suggest a unified error handling strategy if inconsistencies found.
```

### Code Style and Consistency
```
Review [FILE/MODULE] for code style and consistency. Evaluate:
- Naming conventions
- Code formatting consistency
- Comment quality and completeness
- Function length and complexity
- Module organization
- Import/export patterns
- Consistent use of async/await vs promises
- TypeScript/JSDoc type annotations

Suggest improvements for readability and maintainability.
```

## Architecture Templates

### Architecture Review
```
Analyze the architecture of [COMPONENT/SYSTEM]. Read the main files and assess:
- Overall design and structure
- Separation of concerns
- Component dependencies and coupling
- Modularity and reusability
- Scalability considerations
- Data flow and state management
- API design (if applicable)
- Testing strategy

What would you do differently? What are the biggest architectural improvements you'd recommend?
```

### Scalability Analysis
```
Assess the scalability of [COMPONENT/SYSTEM]. Analyze:
- Current performance characteristics
- Bottlenecks at scale (10x, 100x, 1000x load)
- Database scaling strategy
- Caching strategy
- Stateless vs stateful design
- Horizontal vs vertical scaling readiness
- Distributed system concerns (if applicable)
- Resource utilization patterns

Recommend specific scalability improvements with estimated impact.
```

### Design Pattern Consultation
```
Analyze [COMPONENT] and recommend appropriate design patterns.

Current situation: [BRIEF DESCRIPTION]

Requirements:
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

Which design pattern would work best?
Consider: Strategy, Factory, Adapter, Observer, Singleton, Command, etc.

For your recommendation:
- Explain why it fits this use case
- Show how to structure the implementation
- Discuss tradeoffs vs alternatives
```

### Technology Decision
```
We need to choose [TECHNOLOGY TYPE] for [USE CASE].

Options under consideration:
1. [OPTION 1] - [BRIEF DESCRIPTION]
2. [OPTION 2] - [BRIEF DESCRIPTION]
3. [OPTION 3] - [BRIEF DESCRIPTION]

Context:
- Current stack: [TECHNOLOGIES]
- Team expertise: [SKILLS]
- Scale requirements: [SCALE]
- Budget constraints: [CONSTRAINTS]

Analyze each option and provide:
- Pros and cons
- Implementation complexity
- Performance characteristics
- Long-term maintainability
- Your recommendation with justification
```

### API Design Review
```
Review the API design in [FILE/MODULE]. Evaluate:
- RESTful principles adherence
- Endpoint naming conventions
- HTTP method usage (GET, POST, PUT, DELETE, PATCH)
- Status code appropriateness
- Request/response structure consistency
- Query parameter vs path parameter usage
- Pagination strategy
- Filtering and sorting approach
- Error response format
- API versioning strategy
- Authentication/authorization approach
- Rate limiting design

Suggest improvements for consistency and best practices.
```

## Debugging Templates

### Root Cause Analysis
```
We are experiencing [SYMPTOM/ERROR].

Symptoms:
- [SYMPTOM 1]
- [SYMPTOM 2]
- [FREQUENCY/CONDITIONS]

Investigate [FILE/MODULE] for potential causes:
- Analyze the code flow for this scenario
- Identify potential failure points
- Check error handling in relevant code paths
- Look for race conditions or timing issues
- Examine state management

What are the most likely root causes?
For each potential cause:
- Explain why it could cause these symptoms
- Suggest diagnostic steps to confirm
- Recommend fixes with code examples if possible
```

### Intermittent Bug Analysis
```
We have an intermittent issue: [DESCRIPTION]

Characteristics:
- Frequency: [HOW OFTEN]
- Conditions: [WHEN IT HAPPENS]
- Pattern: [ANY OBSERVABLE PATTERN]

Analyze [FILE/MODULE] for:
- Race conditions
- Timing-dependent behavior
- Shared state problems
- Resource exhaustion
- External dependency failures
- Memory leaks
- Concurrency issues

Suggest:
- Diagnostic logging to add
- How to reproduce consistently
- Potential fixes
- Monitoring to implement
```

### Performance Investigation
```
[COMPONENT/OPERATION] is performing poorly.

Symptoms:
- Operation takes [TIME] (expected: [EXPECTED TIME])
- Occurs with [CONDITIONS/DATA SIZE]

Analyze [FILE/MODULE] for performance bottlenecks:
- Algorithm complexity
- Database query efficiency
- Network calls
- File I/O operations
- Synchronous operations in async code
- Memory allocation patterns
- Caching opportunities

For each bottleneck:
- Estimate impact
- Suggest specific optimization
- Provide implementation approach
- Recommend benchmarking strategy
```

### Behavior Analysis
```
[COMPONENT] is behaving unexpectedly.

Expected behavior: [DESCRIPTION]
Actual behavior: [DESCRIPTION]
Input: [INPUT DATA/CONDITIONS]

Analyze [FILE/MODULE] to understand:
- Logic flow for this scenario
- Edge cases that might not be handled
- Assumptions that might be violated
- State changes during execution
- Side effects that might affect behavior

Explain what's happening and why. Suggest fixes.
```

## Implementation Templates

### Refactoring Task
```
Refactor [COMPONENT] to improve [ASPECT: maintainability/performance/testability/etc.].

Current issues:
- [ISSUE 1]
- [ISSUE 2]
- [ISSUE 3]

Goals:
- [GOAL 1]
- [GOAL 2]
- [GOAL 3]

Constraints:
- [CONSTRAINT 1: e.g., maintain backward compatibility]
- [CONSTRAINT 2]

Refactor the code and explain:
- What changes you made
- Why each change improves the code
- Any tradeoffs or risks
- Suggested testing approach
```

### Bug Fix Task
```
Fix the bug: [BUG DESCRIPTION]

Location: [FILE:LINE] or [COMPONENT]
Reproduction steps:
1. [STEP 1]
2. [STEP 2]
3. [STEP 3]

Expected: [EXPECTED BEHAVIOR]
Actual: [ACTUAL BEHAVIOR]

Fix the bug and:
- Explain the root cause
- Describe your fix approach
- Add error handling if missing
- Suggest tests to prevent regression
```

### Feature Implementation
```
Implement [FEATURE DESCRIPTION].

Requirements:
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

Technical constraints:
- [CONSTRAINT 1]
- [CONSTRAINT 2]

Acceptance criteria:
- [CRITERION 1]
- [CRITERION 2]

Implement the feature and explain:
- Design decisions made
- Where code was added/modified
- How to test the feature
- Any edge cases to be aware of
```

## General Consultation Templates

### Second Opinion
```
I'm considering [APPROACH/DECISION]. What do you think?

Context: [BACKGROUND]

My current thinking:
- [RATIONALE 1]
- [RATIONALE 2]

Concerns:
- [CONCERN 1]
- [CONCERN 2]

Alternatives considered:
- [ALTERNATIVE 1]: [WHY REJECTED/UNCERTAIN]
- [ALTERNATIVE 2]: [WHY REJECTED/UNCERTAIN]

Provide your analysis:
- Do you agree with this approach?
- What are the tradeoffs?
- What might I be missing?
- Would you do anything differently?
```

### Code Quality Assessment
```
Assess the overall code quality of [COMPONENT/PROJECT].

Read the codebase and evaluate:
- Code organization and structure
- Naming and readability
- Documentation quality
- Test coverage and quality
- Error handling
- Performance considerations
- Security posture
- Technical debt indicators
- Dependency management

Provide:
- Overall grade (A/B/C/D/F)
- Strengths
- Weaknesses
- Top 5 improvements to prioritize
```

### Modernization Consultation
```
Help modernize [FILE/COMPONENT] written in [OLD STYLE/VERSION].

Current approach: [DESCRIPTION]

Analyze for modernization opportunities:
- ES6+ features that could replace old patterns
- Async/await instead of callbacks
- Modern library replacements for outdated dependencies
- Deprecated API usage
- Type safety opportunities (JSDoc or TypeScript)
- Modern build tools
- Testing framework updates

Propose:
- Quick wins (low effort, high value)
- Medium-term improvements
- Long-term modernization goals
- Migration risks and how to mitigate
```

## Prompt Best Practices

1. **Be Specific**: Name files, components, and concerns explicitly
2. **Provide Context**: Explain the situation and constraints
3. **Request Format**: Specify how you want results (line numbers, severity, etc.)
4. **Set Scope**: Define boundaries to avoid sprawling analysis
5. **Request Actionable Output**: Ask for specific suggestions, not just observations
6. **Prioritize**: Ask for ranking by impact/severity/effort
7. **Include Examples**: If relevant, provide example inputs/outputs

## Template Customization Tips

### Make It Specific
- Bad: "Review the code"
- Good: "Review src/auth/login.js for security issues, focusing on authentication bypass vulnerabilities and session management"

### Provide Context
- Bad: "Fix the performance issue"
- Good: "The user dashboard loads in 5 seconds with 1000 users. We need it under 1 second. Analyze src/dashboard.js for performance bottlenecks."

### Request Structured Output
- Bad: "Tell me what you think"
- Good: "Rate each finding as Critical/High/Medium/Low and provide specific line numbers with actionable suggestions"

### Define Success Criteria
- Bad: "Make it better"
- Good: "Refactor to reduce cyclomatic complexity below 10 while maintaining 100% test coverage"
