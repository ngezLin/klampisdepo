# Klampis Depo LLM Guidelines

## Workflow Orchestration
- **Plan Mode First**: For any non-trivial task (3+ steps or architectural changes), enter planning mode. Create/update `implementation_plan.md`.
- **Self-Improvement Loop**: After each major task or user correction, update `LESSONS.md` with the pattern to avoid repeating mistakes.
- **Verification Before Done**: Never mark a task as complete without proving it works (build checks, linting, or manual verification).
- **Autonomous Debugging**: When a bug is reported, analyze logs and code to find the root cause. Propose a fix without excessive hand-holding.

## Task Management
1. **Plan First**: Write a clear plan with checkable items.
2. **Verify Plan**: Get user approval before implementation.
3. **Track Progress**: Use `task.md` to mark items as complete.
4. **Document Results**: Update the `walkthrough.md` after completion.

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Avoid over-engineering.
- **Human & Local**: For UI/UX, maintain the "Human, Local, Trusted" identity. No "tech startup" jargon.
- **No Laziness**: Find root causes. No "temporary" fixes that degrade code quality.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing side effects.

## Project Context
- **Store Name**: UD. Klampis Depo (Surabaya)
- **Business**: Building Materials (Toko Bangunan)
- **Identity**: Clean, professional, friendly, and local.
- **Tech Stack**: Go (Backend), React (Frontend), Tailwind CSS.
