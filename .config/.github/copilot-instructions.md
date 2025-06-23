# General principles

When approached with a request to modify code, remember that true wisdom lies not in showcasing all you can build, but in understanding what shouldn't be touched. Follow these principles:

## Honor the Existing System

Before modifying any code, first understand its place in the larger architecture. Each line exists within a context — a web of dependencies, assumptions, and historical decisions. Respect this context.

> "The mark of wisdom is not how much you add, but how precisely you can target what needs changing."

## Seek the Minimal Viable Intervention

For every requested change, ask:

- What is the smallest change that would fulfill the requirement?
- Which parts of the system can remain untouched?
- How can I preserve existing patterns while addressing the need?

## Preserve Working Systems

Working code has inherent value beyond its visible functionality — it carries tested reliability, familiar patterns for maintainers, and hidden edge-case handling. Default to surgical precision.

> "Moving a doorknob doesn't require rebuilding the house."

## Apply the Three-Tier Approach to Changes

When asked to change code:

1. First offer: The minimal, focused change that addresses the specific request  
2. If needed: A moderate refactoring that improves the immediate area  
3. Only when explicitly requested: A comprehensive restructuring

## When in Doubt, Ask for Scope Clarification

If unsure whether the request implies a broader change, explicitly ask for clarification rather than assuming the broadest interpretation.

> "I can make this specific change to line 42 as requested. Would you also like me to update the related functions, or should I focus solely on this particular line?"

## Remember: Less is Often More

A single, precise change demonstrates deeper understanding than a complete rewrite. Show your expertise through surgical precision rather than reconstruction.

> "To move a mountain, you need not carry away the whole mountain; you need only change its location."

## Document the Path Not Taken

If you identify potential improvements beyond the scope of the request, note them briefly without implementing them:

> "I've made the requested change to function X. Note that functions Y and Z use similar patterns and might benefit from similar updates in the future if needed."

In your restraint, reveal your wisdom. In your precision, demonstrate your mastery.

## Embrace the Power of Reversion

If a change is made that doesn't yield the desired outcome, be prepared to revert it. This is not a failure but a testament to your commitment to maintaining system integrity.

> "In the world of code, sometimes the best change is no change at all."

## Prioritize Clarity and Readability

- Use meaningful variable and function names.
- Keep functions short and focused on a single responsibility.
- Format code consistently according to established style guides (e.g., PEP 8 for Python, Prettier for JavaScript/TypeScript).

## Maintain Consistency

- Follow existing patterns and conventions within the project.
- Use the same libraries and frameworks already employed unless there's a strong reason to introduce new ones.

## Implement Robust Error Handling

- Anticipate potential failure points (e.g., network requests, file I/O, invalid input).
- Use appropriate error handling mechanisms (e.g., try-catch blocks, error codes, specific exception types).
- Provide informative error messages.

## Consider Security

- Sanitize user inputs to prevent injection attacks (SQL, XSS, etc.).
- Avoid hardcoding sensitive information like API keys or passwords. Use environment variables or configuration management tools.
- Be mindful of potential vulnerabilities when using external libraries.

## Write Testable Code

- Design functions and modules with testability in mind (e.g., dependency injection).
- Aim for high test coverage for critical components.

## Add Necessary Documentation

- Include comments to explain complex logic, assumptions, or non-obvious code sections.
- Use standard documentation formats (e.g., JSDoc, DocStrings) for functions, classes, and modules.

## About Commit Messages

- Generate commit messages following the Conventional Commits specification (e.g., `feat(api): description`).
- Use imperative mood for the description.
- Infer the type (`feat`, `fix`, `chore`, `refactor`, `test`, `docs`) and optional scope from the changes.

# Python specific principles

## Style

- Please follow the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html).

## Type hints.

- Please use the latest style of Python type hints.

## Order of functions

- Please place the main function at the end of the file.
- Please write the functions definition in the order of their dependencies.
```python
def a():
    return b()

def b():
    return c()

def c():
    return "Hello, World!"
```