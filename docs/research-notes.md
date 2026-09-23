# Research Notes: AI Agents and Low-Value Code Comments

## Main finding

The practical rule is stable across engineering guides and developer discussions: comments should preserve intent and context that the code cannot express, while redundant "what this line does" comments and edit-history comments should be kept out of the repository.

## Evidence map

- Google Engineering Practices says reviewers should ask whether comments are necessary and notes that comments are usually useful when they explain why code exists, not what the code does.
- GitHub Community discussions show developers repeatedly report that Copilot can generate redundant comments, including comments that mirror obvious line-level operations.
- Research on code-comment consistency treats stale comments as a maintenance risk because comments can become inconsistent with code after edits.
- Research on LLM-generated comments found that generated comments can contain demonstrably inaccurate statements, which supports using a guardrail rather than relying only on prompts.
- Recent work on agent-generated code review comments suggests long or incorrect AI feedback often fails to resolve cleanly, which reinforces the need for short, enforceable workflow rules.

## Sources

1. Google Engineering Practices. "What to look for in a code review." https://google.github.io/eng-practices/review/reviewer/looking-for.html
2. GitHub Community Discussion #59697. "Copilot Chat - Excessive comments in generated code." https://github.com/orgs/community/discussions/59697
3. GitHub Community Discussion #157778. "i would like the ability to stop co-pilot from writing comments." https://github.com/orgs/community/discussions/157778
4. Huang, Y., Chen, Y., Chen, X., and Zhou, X. "Are your comments outdated? Towards automatically detecting code-comment consistency." arXiv:2403.00251. https://arxiv.org/abs/2403.00251
5. Kang, S., Milliken, L., and Yoo, S. "Identifying Inaccurate Descriptions in LLM-generated Code Comments via Test Execution." arXiv:2406.14836. https://arxiv.org/abs/2406.14836
6. Cynthia, S. T., Widyasari, R., Roy, B., Zhang, T., and Lo, D. "Go Home Copilot, You're Drunk: Understanding Developer Responses to Agent-Generated Code Review Comments." arXiv:2607.21997. https://arxiv.org/abs/2607.21997
