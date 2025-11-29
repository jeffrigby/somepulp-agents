# AI Consultation Examples

This document provides concrete examples of different types of AI consultations with effective prompts and expected workflows.

## Example 1: Comprehensive Code Review

### Scenario
User asks: "Can you get a second opinion on the index.js file?"

### Consultation Type
Code Review (read-only)

### Prompt
```
Perform a comprehensive code review of index.js. Focus on:
1. Code quality and maintainability
2. Error handling and edge cases
3. Security vulnerabilities
4. Performance considerations
5. Best practices and patterns
Provide specific line numbers and actionable suggestions.
```

### Expected Workflow
1. AI reads index.js
2. Analyzes code structure, patterns, error handling
3. Identifies specific issues with line numbers
4. Provides actionable recommendations
5. May suggest alternative approaches

### How to Present Results
- Highlight critical security issues first
- Group findings by category (security, performance, maintainability)
- Compare AI findings with your own analysis
- Note any disagreements or alternative perspectives
- Provide prioritized action items

## Example 2: Architecture Discussion

### Scenario
User asks: "What would an AI think about our MCP gateway architecture?"

### Consultation Type
Architecture Opinion (read-only)

### Prompt
```
Analyze the architecture of this MCP gateway project. Read the main files and assess:
- Overall design and structure
- Separation of concerns
- Scalability considerations
- Potential architectural improvements
What would you do differently?
```

### Expected Workflow
1. AI explores project structure
2. Reads key files (index.js, package.json, README, etc.)
3. Analyzes component relationships
4. Evaluates against best practices
5. Suggests architectural improvements

### How to Present Results
- Summarize current architecture understanding
- Present AI's key observations
- Highlight suggested improvements
- Compare with your own architectural assessment
- Discuss trade-offs of suggested changes

## Example 3: Bug Investigation

### Scenario
User asks: "Ask the AI why the SSE connection keeps dropping"

### Consultation Type
Debugging Consultation (read-only)

### Prompt
```
We have SSE connections that intermittently drop. Investigate the codebase for:
- How SSE connections are handled
- Potential timeout issues
- Error handling gaps
- Race conditions
What are the most likely causes and how would you fix them?
```

### Expected Workflow
1. AI searches for SSE-related code
2. Analyzes connection lifecycle
3. Identifies potential failure points
4. Suggests diagnostic approaches
5. Proposes fixes with code examples

### How to Present Results
- List most likely root causes
- Provide diagnostic steps to confirm each hypothesis
- Share AI's suggested fixes
- Evaluate feasibility of each fix
- Recommend next debugging steps

## Example 4: Security Audit

### Scenario
User asks: "Get a security review of the authentication module"

### Consultation Type
Security Review (read-only)

### Prompt
```
Perform a security audit of src/auth.js. Check for:
- Authentication bypass vulnerabilities
- Authorization issues
- Session management problems
- Input validation gaps
- Token handling security
- Timing attacks
- Information disclosure
Rate severity (Critical/High/Medium/Low) for each finding.
```

### Expected Workflow
1. AI analyzes authentication flow
2. Checks for OWASP Top 10 vulnerabilities
3. Examines token generation and validation
4. Reviews session handling
5. Provides severity-rated findings

### How to Present Results
- Prioritize by severity (Critical -> High -> Medium -> Low)
- Explain each vulnerability clearly
- Provide proof-of-concept where appropriate
- Include remediation steps
- Compare with your own security analysis

## Example 5: Performance Analysis

### Scenario
User asks: "Why is the data processing so slow?"

### Consultation Type
Performance Investigation (read-only)

### Prompt
```
Analyze src/processor.js for performance issues. Look for:
- Inefficient algorithms (O(n²) or worse)
- Unnecessary synchronous operations
- Memory leaks
- Excessive object creation
- Database query inefficiencies
- Missing caching opportunities
Suggest specific optimizations with expected impact.
```

### Expected Workflow
1. AI analyzes computational complexity
2. Identifies blocking operations
3. Finds optimization opportunities
4. Estimates performance impact
5. Suggests benchmarking approaches

### How to Present Results
- List bottlenecks by impact (highest first)
- Explain why each is slow
- Provide optimization suggestions
- Estimate performance gains
- Recommend profiling tools

## Example 6: Refactoring Consultation

### Scenario
User asks: "Should we refactor this into smaller modules?"

### Consultation Type
Refactoring Opinion (read-only initially)

### Prompt
```
Analyze src/monolith.js for refactoring opportunities. Consider:
- Single Responsibility Principle violations
- Suggested module boundaries
- Dependencies that could be decoupled
- Shared code that should be extracted
Propose a refactoring plan with module structure.
```

### Expected Workflow
1. AI analyzes current code structure
2. Identifies logical boundaries
3. Suggests module organization
4. Proposes refactoring steps
5. Discusses trade-offs

### How to Present Results
- Show proposed module structure
- Explain rationale for each module
- Discuss refactoring risks
- Suggest phased approach
- Compare with your own refactoring ideas

## Example 7: Design Pattern Recommendation

### Scenario
User asks: "What design pattern should we use for this use case?"

### Consultation Type
Design Consultation (read-only)

### Prompt
```
We need to handle multiple email transport providers (SendGrid, SparkPost, SMTP).
Currently in src/transport.js. Which design pattern would work best?
- Strategy Pattern
- Factory Pattern
- Adapter Pattern
- Plugin Architecture
Analyze the current code and recommend the most appropriate pattern with justification.
```

### Expected Workflow
1. AI reads current implementation
2. Analyzes requirements and constraints
3. Evaluates pattern options
4. Recommends best fit
5. May provide implementation sketch

### How to Present Results
- Present recommended pattern with rationale
- Explain why it fits this use case
- Discuss trade-offs vs. alternatives
- Show implementation structure
- Compare with your own pattern preference

## Example 8: Dependency Analysis

### Scenario
User asks: "Are we using too many dependencies?"

### Consultation Type
Dependency Audit (read-only)

### Prompt
```
Analyze package.json dependencies. For each dependency:
- Is it actively maintained?
- Are there lighter alternatives?
- Can functionality be implemented without it?
- Are we using it effectively?
Suggest dependencies to remove, replace, or keep with rationale.
```

### Expected Workflow
1. AI reads package.json
2. Checks how each dependency is used
3. Researches alternatives
4. Evaluates necessity
5. Provides recommendations

### How to Present Results
- Categorize: Remove, Replace, Keep
- Explain rationale for each
- Suggest alternative implementations
- Estimate impact of changes
- Prioritize by value/effort

## Example 9: Error Handling Review

### Scenario
User asks: "Review our error handling strategy"

### Consultation Type
Code Review (read-only)

### Prompt
```
Analyze error handling across the codebase. Check:
- Consistency of error handling patterns
- Appropriate use of try/catch
- Error logging completeness
- User-facing error messages
- Error recovery strategies
- Unhandled promise rejections
Suggest a unified error handling strategy.
```

### Expected Workflow
1. AI scans codebase for error handling
2. Identifies patterns and inconsistencies
3. Evaluates current approach
4. Suggests standardization
5. Proposes error handling framework

### How to Present Results
- Document current error patterns
- Highlight inconsistencies
- Present recommended strategy
- Show example implementation
- Create migration plan

## Example 10: API Design Review

### Scenario
User asks: "Review the REST API design"

### Consultation Type
API Review (read-only)

### Prompt
```
Review the REST API design in src/api/. Evaluate:
- RESTful principles adherence
- Endpoint naming conventions
- HTTP method usage
- Status code appropriateness
- Request/response structure
- Versioning strategy
- Error response format
Suggest improvements for consistency and best practices.
```

### Expected Workflow
1. AI analyzes API endpoints
2. Checks REST compliance
3. Evaluates consistency
4. Compares to best practices
5. Suggests improvements

### How to Present Results
- Grade current API design
- List non-RESTful patterns
- Suggest endpoint restructuring
- Recommend naming improvements
- Provide example requests/responses

## Example 11: Test Coverage Analysis

### Scenario
User asks: "Where should we add more tests?"

### Consultation Type
Test Strategy (read-only)

### Prompt
```
Analyze test coverage and gaps. Compare src/ with test/:
- Which modules lack tests?
- Which edge cases aren't covered?
- Are critical paths well-tested?
- Test quality assessment
Prioritize areas needing tests by risk/impact.
```

### Expected Workflow
1. AI compares source and test files
2. Identifies untested modules
3. Analyzes test quality
4. Assesses risk areas
5. Prioritizes testing needs

### How to Present Results
- List untested modules
- Identify critical gaps
- Prioritize by risk
- Suggest test scenarios
- Estimate testing effort

## Example 12: Code Modernization

### Scenario
User asks: "Help modernize this legacy code"

### Consultation Type
Modernization Consultation (read-only)

### Prompt
```
Analyze src/legacy.js for modernization opportunities:
- ES6+ features that could replace old patterns
- Async/await instead of callbacks
- Modern library replacements
- Deprecated API usage
- Type safety opportunities (JSDoc or TypeScript)
Propose a modernization roadmap.
```

### Expected Workflow
1. AI identifies legacy patterns
2. Suggests modern equivalents
3. Evaluates migration complexity
4. Proposes phased approach
5. Discusses benefits and risks

### How to Present Results
- Show legacy vs. modern comparison
- Propose migration phases
- Estimate effort per phase
- Discuss breaking changes
- Create modernization checklist

## Tips for Effective Consultations

### Crafting Good Prompts
- Be specific about what to analyze
- List concrete aspects to check
- Specify desired output format
- Include context about the problem
- Request line numbers for code issues

### Processing AI Output
- Read critically - don't accept blindly
- Compare with your own analysis
- Highlight novel insights
- Validate suggestions before presenting
- Synthesize best ideas from both perspectives

### Presenting to Users
- Start with executive summary
- Prioritize by impact/severity
- Use clear categories
- Provide actionable next steps
- Acknowledge limitations or uncertainties
