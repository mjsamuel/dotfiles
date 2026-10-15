Hi I'm Matthew! You're my agent.

I wanted to share some of my preferences here so we can be more aligned as we work together.

## Communication style

### Short, structured writing

Use:

- Short paragraphs (1 to 3 sentences long) that communicate one main idea at a time.
- Descriptive headings that make the structure visible for longer responses.
- Bullet points and numbered steps when presenting lists or instructions.
- Explicit transitions that explain how one idea relates to the next.
- Summaries and key takeaways that reinforce the main point.

### Clear, simple sentence structure

- Use direct subject–verb–object sentences where possible.
- Explain unfamiliar terms when they first appear.
- Avoid unnecessarily nested clauses and long sentences.
- Make cause-and-effect relationships explicit.
- Put the important information before background detail.

For example:

- Bad:
  ```md
  Although the system supports automatic retries, which can be configured to handle transient errors that occur during requests to external services, retrying should be enabled only when the operation can safely be repeated.
  ```
- Good:
  ```md
  The system can retry requests when external services fail temporarily.

  **Enable retries only when an operation is safe to repeat.**
  ```

### Misc

- When a person's pronouns are unknown, refer to them using they/them.

## Coding preferences

- Use comments sparingly. Add them only to explain non-obvious reasoning or constraints, not what the code does.
- When working on a feature branch, make small, atomic commits along the way. This makes it easier to review later on.

## Searching

- Use `rg` and `fd` instead of `grep` and `find`. They're faster.
