# AI Consultation Quality Checklist

This checklist ensures thorough, high-quality AI consultations. Use it to verify that nothing important is missed.

## Pre-Consultation Checklist

### Request Analysis
- [ ] **Consultation type identified** (code review, architecture, debugging, implementation)
- [ ] **User's goal is clear** (what they want to achieve)
- [ ] **Specific concerns identified** (security, performance, etc.)
- [ ] **Scope defined** (which files/components to analyze)
- [ ] **Expected output understood** (what format user wants)

### Context Gathering
- [ ] **Relevant files identified** (know what AI should read)
- [ ] **Background information available** (constraints, requirements)
- [ ] **User's current understanding documented** (to compare later)
- [ ] **Success criteria defined** (how to know consultation succeeded)

### Configuration
- [ ] **Safety mode determined**
  - Read-only/Sandbox for analysis/review
  - Write mode for changes (with user confirmation)
- [ ] **Working directory set**
- [ ] **Prompt prepared and reviewed**

## Prompt Preparation Checklist

### Prompt Quality
- [ ] **Specific and actionable** (not vague or general)
- [ ] **Includes file paths** (tells AI what to analyze)
- [ ] **Describes expected output** (format, level of detail)
- [ ] **Provides context** (relevant background information)
- [ ] **Sets clear scope** (boundaries of analysis)
- [ ] **Requests prioritization** (by severity, impact, effort, etc.)

### Prompt Structure
- [ ] **Clear action verb** ("Analyze", "Review", "Investigate")
- [ ] **Specific aspects to check** (bulleted list of concerns)
- [ ] **Output format specified** (line numbers, severity ratings, etc.)
- [ ] **Prioritization criteria** (what matters most)

### Red Flags to Avoid
- [ ] **Not too vague** (Bad: "Review the code" -> Good: "Review src/auth.js for security")
- [ ] **Not too broad** (Bad: "Analyze everything" -> Good: "Analyze user authentication flow")
- [ ] **Not missing context** (include relevant constraints)
- [ ] **Not lacking direction** (specify what you want to know)

## Post-Consultation Checklist

### Output Review
- [ ] **AI completed successfully** (no errors or timeouts)
- [ ] **Output received and readable** (not truncated or garbled)
- [ ] **Output is substantive** (actually addresses the request)
- [ ] **Line numbers provided** (if code issues found)
- [ ] **Severity ratings included** (if requested)

### Critical Analysis
- [ ] **Evaluated AI's findings critically** (not blindly accepted)
- [ ] **Compared with own analysis** (identified agreements/differences)
- [ ] **Validated suggestions** (checked if they make sense)
- [ ] **Checked for hallucinations** (verified claims against actual code)
- [ ] **Assessed actionability** (can suggestions actually be implemented?)
- [ ] **Considered context** (does AI understand the full picture?)

### Findings Processing
- [ ] **Findings categorized** (by type: security, performance, style, etc.)
- [ ] **Findings prioritized** (by severity or impact)
- [ ] **Duplicates removed** (if AI repeated itself)
- [ ] **False positives filtered** (incorrect findings)
- [ ] **Novel insights identified** (things you didn't notice)
- [ ] **Disagreements noted** (where you disagree with AI)

## Synthesis Checklist

### Combining Perspectives
- [ ] **Own analysis documented** (what you think)
- [ ] **AI's analysis documented** (what AI thinks)
- [ ] **Agreements highlighted** (where both agree)
- [ ] **Differences explained** (where perspectives diverge)
- [ ] **Best insights from both** (synthesized recommendation)

### Quality Validation
- [ ] **Recommendations are actionable** (specific steps to take)
- [ ] **Tradeoffs explained** (pros and cons of suggestions)
- [ ] **Priorities clear** (what to do first)
- [ ] **Risks identified** (potential downsides)
- [ ] **Alternative approaches considered** (not just one way)

## Presentation Checklist

### Structure
- [ ] **Executive summary prepared** (high-level overview)
- [ ] **Findings organized logically** (by category or priority)
- [ ] **Key insights highlighted** (most important points)
- [ ] **Action items clear** (specific next steps)
- [ ] **Supporting details available** (for user questions)

### Content Quality
- [ ] **Accurate information** (facts checked)
- [ ] **Clear language** (no jargon without explanation)
- [ ] **Specific examples** (concrete code references)
- [ ] **Line numbers included** (for code issues)
- [ ] **Balanced perspective** (not just negative, acknowledge strengths)

### Completeness
- [ ] **All user questions answered** (addressed original request)
- [ ] **Limitations acknowledged** (what AI might have missed)
- [ ] **Confidence level indicated** (certainty of recommendations)
- [ ] **Follow-up suggestions** (what to investigate next)
- [ ] **Attribution clear** (which insights came from AI)

## Type-Specific Checklists

### Code Review Checklist
- [ ] **Security issues identified** (with severity ratings)
- [ ] **Performance concerns noted** (with impact estimates)
- [ ] **Code quality issues listed** (maintainability, readability)
- [ ] **Best practices violations** (what standards not followed)
- [ ] **Error handling reviewed** (gaps identified)
- [ ] **Testing gaps noted** (what's not tested)
- [ ] **Documentation issues** (missing or outdated docs)
- [ ] **Specific line numbers** (for each issue)
- [ ] **Actionable fixes** (how to resolve each issue)
- [ ] **Prioritization** (what to fix first)

### Architecture Review Checklist
- [ ] **Overall design evaluated** (strengths and weaknesses)
- [ ] **Separation of concerns assessed** (modularity)
- [ ] **Scalability analyzed** (bottlenecks at scale)
- [ ] **Component coupling reviewed** (dependencies)
- [ ] **Patterns evaluated** (appropriate design patterns?)
- [ ] **Alternative approaches** (what AI would do differently)
- [ ] **Improvement priorities** (biggest wins)
- [ ] **Migration path** (how to get from here to there)
- [ ] **Tradeoffs explained** (costs vs benefits)

### Debugging Consultation Checklist
- [ ] **Symptoms understood** (what's actually happening)
- [ ] **Root causes hypothesized** (likely reasons)
- [ ] **Diagnostic steps suggested** (how to confirm)
- [ ] **Code paths analyzed** (where problem might be)
- [ ] **Potential fixes proposed** (how to resolve)
- [ ] **Prevention measures** (avoid recurrence)
- [ ] **Monitoring recommendations** (how to detect early)
- [ ] **Testing strategy** (verify fix works)
- [ ] **Priority ranking** (which hypothesis to test first)

## Common Pitfalls to Avoid

### Analysis Errors
- [ ] **Not blindly accepting AI's opinion** (always validate)
- [ ] **Not ignoring own expertise** (trust your judgment)
- [ ] **Not overlooking context** (AI might miss bigger picture)
- [ ] **Not accepting hallucinations** (verify claims)
- [ ] **Not skipping validation** (check suggestions make sense)

### Process Errors
- [ ] **Not using write mode without confirmation** (dangerous)
- [ ] **Not being too vague in prompts** (get specific)
- [ ] **Not forgetting to compare perspectives** (both matter)
- [ ] **Not presenting AI as infallible** (it can be wrong)
- [ ] **Not skipping critical thinking** (evaluate everything)

### Communication Errors
- [ ] **Not overwhelming user with details** (summarize first)
- [ ] **Not hiding limitations** (be honest about uncertainties)
- [ ] **Not missing action items** (give clear next steps)
- [ ] **Not forgetting to synthesize** (combine perspectives)
- [ ] **Not being unclear about source** (attribute insights)

## Success Criteria

### Minimum Success
- [ ] AI provided substantive feedback
- [ ] Response was relevant to the request
- [ ] User received actionable information
- [ ] No errors during execution

### Good Success
- [ ] Novel insights identified (things not noticed before)
- [ ] Findings were validated and accurate
- [ ] Clear action items provided
- [ ] Comparison with own analysis completed
- [ ] User satisfied with consultation

### Excellent Success
- [ ] Multiple valuable insights discovered
- [ ] Disagreements thoughtfully analyzed
- [ ] Comprehensive synthesis provided
- [ ] User gained new understanding
- [ ] Follow-up path clear
- [ ] Consultation saved significant time/effort

## Quick Pre-Flight Check

Before every consultation, verify:

1. **Know what you're asking** (clear goal)
2. **Prompt is specific** (not vague)
3. **Safety mode appropriate** (read-only vs write)
4. **Ready to critically evaluate** (not blind acceptance)
5. **Have time to synthesize** (not just forward AI output)

## Emergency Checklist

If consultation goes wrong:

### AI Times Out
- [ ] Narrow the scope (analyze less code)
- [ ] Be more specific (clearer focus)
- [ ] Try again with simpler request
- [ ] Fall back to own analysis

### AI Output Not Helpful
- [ ] Acknowledge to user
- [ ] Provide own analysis instead
- [ ] Refine prompt and try again (if time)
- [ ] Learn from what didn't work

### User Disagrees with AI
- [ ] Explain AI's reasoning
- [ ] Present your analysis
- [ ] Acknowledge uncertainty
- [ ] Let user decide
- [ ] Document the disagreement

## Final Validation

Before presenting to user:

- [ ] Information is accurate
- [ ] Recommendations are actionable
- [ ] Critical thinking applied
- [ ] Both perspectives considered
- [ ] Clear next steps provided
- [ ] User's question fully answered
- [ ] Limitations acknowledged
- [ ] Value added (not just parroting)
