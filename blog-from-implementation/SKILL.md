---
name: blog-from-implementation
description: Surface interesting narrative angles from a feature you just built. Use when user wants to write a blog post about something they implemented, or says "I want to blog about this", "what is worth writing about here", "turn this into a post", "let us write a post about what we just discussed".
---
# blog-from-implementation

## Quick start

Invoke at the end of a conversation about something you built, or point at a codebase:

```
/blog-from-implementation                        # mines the current conversation
/blog-from-implementation src/recommendations/   # reads git + source files
/blog-from-implementation                        # PR #142, plus use this conversation
```

## Workflow

### Step 1: Detect context and source the material

Determine mode without asking — figure it out from available tools and conversation length.

**Chat mode** (no filesystem access, or long prior conversation about the feature):
Read back through the current conversation. Extract:
- **Decision moments**: "I could do X or Y" pivots, approaches abandoned mid-conversation, places where framing shifted
- **Constraint discoveries**: "Oh wait, that doesn't work because...", moments where the problem turned out to be different than expected
- **Rejected options**: approaches discussed but not taken — often more valuable to readers than what was chosen
- **Hindsight**: "so the real issue was...", "in retrospect..." — things that only made sense at the end

Do not ask the user to summarize. Read it yourself.

**Code mode** (filesystem access, file paths or PR provided):
Read `git log --oneline`, key diffs, source files, inline comments (especially *why* comments), and tests. Look for: commented-out approaches, complexity disproportionate to the goal, deceptively clean code with a hard-won story behind it, abstractions that encode a bet about the future, schema or API decisions that seem oddly specific.

**Hybrid**: do both. Then look for gaps — decisions in the conversation not visible in the code, and code complexity whose explanation lives in the conversation.

### Step 2: Ask 3–5 pointed questions

Based on what you actually found — not generic prompts. Reference specifics:
- "You considered X early on but ended up with Y — what changed?"
- "This [method/schema] seems to be doing more work than expected — was there a simpler version you rejected?"
- "There's a moment where you said [thing] — what was happening there?"

Only ask what you genuinely cannot answer from the source material.

### Step 3: Propose 2–3 narrative angles

Each angle as a brief. Angles should be genuinely different — different readers, different hooks, not just different phrasings of the same post.

```
## Angle N: [title that captures the story, not the feature name]
Hook: one sentence — the surprising or counterintuitive thing
Arc:
  Problem: what constraint or goal forced the decision
  Options: what was considered
  Decision: what was chosen and the core reason
  10x thing: what a reader can apply faster than you did
Source: conversation / code / both
Best for: [reader type]
Depth: <1000 words / 1000–2000 / deep dive
```

### Step 4: Brief, then draft

Produce a post brief and get confirmation before writing:

```
Working title:
Hook / first sentence:
Sections (1 sentence each):
Examples: [specific code snippets or conversation moments to use]
Out of scope:
Tone: tutorial / narrative / opinion / reference
```

Then draft. Use real examples from source material — actual code, actual conversation moments, not invented ones.

## Voice constraints

- First person, author's perspective
- Never open with "In this post I'll..." or "Today we're going to..."
- No "Conclusion" header, no filler transitions
- Specific beats general: "sub-100ms p99" beats "fast"
- Show the dead end, not just the solution
- Include moments where the author was wrong — that's what readers actually learn from
