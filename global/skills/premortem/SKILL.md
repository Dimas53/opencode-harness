---
name: premortem
description: "Run a premortem on any plan, launch, product, hire, strategy, or decision. Assumes it already failed 6 months from now and works backward to find every reason why. Produces a revised plan with blind spots exposed. MANDATORY TRIGGERS: 'premortem this', 'premortem my', 'run a premortem', 'what could kill this', 'future-proof this', 'stress test this plan', 'what am i missing here', 'find the blind spots'. STRONG TRIGGERS: 'what could go wrong', 'am i missing anything', 'poke holes in this', 'where will this break', 'devil's advocate this'. Do NOT trigger on simple feedback requests, factual questions. DO trigger when someone has a plan or commitment where the cost of being wrong is high."
---

# Premortem

A premortem is the opposite of a postmortem. Instead of figuring out what went wrong after
something fails, you imagine it already failed and figure out why before you start.

The method comes from psychologist Gary Klein. Daniel Kahneman (Nobel Prize winner,
"Thinking, Fast and Slow") called it his single most valuable decision-making technique.
Google, Goldman Sachs, and P&G all use it before major decisions.

Core insight: when you ask "what could go wrong?" people give cautious, hedged answers.
When you say "this already failed, tell me why" — brains switch into narrative mode and
generate far more specific, honest reasons. Researchers called this "prospective hindsight."

Why this matters for AI: Claude defaults to agreeable, optimistic responses.
The premortem breaks this pattern by forcing the frame: "this is dead, explain how it died."

---

## When to run a premortem

Good targets:
- A product or feature you're about to build
- A launch plan with money or reputation on the line
- A pricing change or business model shift
- A hire you're about to make
- A strategy or positioning pivot
- Any commitment where the cost of being wrong is high

Bad targets:
- Vague ideas with no concrete plan yet (help them plan first)
- Decisions already made and irreversible
- Simple factual questions

---

## Step 1 — Context Gathering

Before running the premortem, gather context. Scan what's available:

**A. Current conversation** — read back through for any plan, product, or decision discussed.

**B. Project files** — quickly check:
- `AGENTS.md` (project context, constraints)
- `docs/ARCHITECTURE.md`, `docs/roadmap.md`
- Any files the user referenced or attached

You need three things minimum:
1. **What is it?** — describe it in one sentence
2. **Who is it for?** — audience, customers, stakeholders
3. **What does success look like?** — you can't define failure without knowing success

If any of these is missing — ask ONE question at a time. Stop asking when you have enough.
Never ask more than you need. Infer from context when possible.

---

## Step 2 — Set the Frame

After gathering context, say explicitly:

> "OK. Here's the premise: it's 6 months from now. [The plan] has failed.
> It's done. We're looking back trying to understand what went wrong."

This framing matters. It shifts from "evaluate this plan" to "explain why this died."

---

## Step 3 — Generate Failure Reasons

Run the raw premortem as a comprehensive analysis:

- Generate every genuine reason the plan could have failed
- Be specific — ground every reason in the actual details of the plan
- Don't pad with weak reasons, don't stop early if there are more
- Each failure reason: 1-2 sentences, specific, genuine threat

The number should match reality — some plans have 4 failure modes, others have 9.

---

## Step 4 — Deep Dive on Each Failure Reason

For each failure reason identified in Step 3, analyze it in depth:

### For each failure reason, produce:

**1. THE FAILURE STORY**
A 2-3 paragraph narrative of how this specific failure played out.
Use details from the plan. Name specific moments where things went wrong and why.
Make it feel real — like a case study of something that actually happened.

**2. THE UNDERLYING ASSUMPTION**
The one thing the user was taking for granted that made this failure possible.
State it in one sentence.

**3. EARLY WARNING SIGNS**
1-2 concrete, observable signals the user could watch for that indicate
this failure mode is starting to play out. Things you can actually see or measure.

Keep each analysis focused and direct. Don't hedge. Don't sugarcoat.

---

## Step 5 — Synthesis

After analyzing all failure reasons, produce the synthesis:

### PREMORTEM REPORT

**1. The Most Likely Failure**
Which failure scenario is most probable given what you know? Why?
This is what the user should focus on first.

**2. The Most Dangerous Failure**
Which failure would cause the most damage if it happened, even if less likely?
This is worth insuring against regardless of probability.

**3. The Hidden Assumption**
Across all failure analyses, what's the single biggest assumption the user is making
that they probably haven't questioned? This is often where the real value lives.

**4. The Revised Plan**
Based on failure scenarios, what specific changes would make the plan more resilient?
Be concrete. Don't say "consider your pricing." Say "test pricing at $X with 20 people
before committing publicly." Each revision should map to a specific failure scenario.

**5. The Pre-Launch Checklist**
3-5 specific things the user should verify, test, or put in place before executing.
Each one should prevent or detect one of the failure modes identified.

---

## Step 6 — Save Report

Save the premortem report as a markdown file in the project:

**File:** `docs/premortem-[topic]-[YYYY-MM-DD].md`

If `docs/` doesn't exist — save to project root or ask where to save.

Structure of the saved file:
```
# Premortem: [Topic]
Date: [date]

## Context
[What, who, success criteria]

## Failure Reasons Found
[numbered list]

## Deep Dives
[one section per failure reason with story, assumption, warning signs]

## Synthesis
[most likely, most dangerous, hidden assumption, revised plan, checklist]
```

After saving, confirm the file path to the user.

---

## Important Rules

- **Always set the premortem frame explicitly** — "this has already failed" is the
  psychological mechanism that makes this work. Without it, the analysis defaults
  to polite risk assessment.

- **Be comprehensive but not padded** — find every genuine failure reason.
  Don't stop at 3 if there are 7. Don't force 7 if there are only 3.

- **The synthesis is the product** — most users will read the synthesis and skim
  the details. Make it specific and actionable.

- **Don't sugarcoat** — the whole point is to tell the user things they don't want
  to hear before reality does. If a plan has serious problems, say so directly.

- **The revised plan must be concrete** — every revision should be something
  the user can actually do this week.

- **Respect the minimum context threshold** — running a premortem on insufficient
  context produces generic failures that waste the user's time.

---

## Example

**User:** "premortem this: I'm launching a $297 workshop on using Claude for marketing teams.
50 seats. Targeting marketing managers at companies with 10-50 employees."

**Raw premortem finds 6 failure reasons:**
1. Marketing managers need approval to spend $297 — friction not accounted for
2. "Claude for marketing" is tool-specific in a market still figuring out if AI is relevant
3. Actual buyers might be solopreneurs, not team managers — content/audience mismatch
4. Demo environments with realistic marketing data take 5 weeks prep, not the 2 budgeted
5. Solopreneur reviews won't resonate with future marketing manager buyers
6. Max revenue $14,850 may not justify prep time vs other opportunities

**Synthesis:** Most likely failure — audience mismatch (managers need approval = friction).
Most dangerous — attracting solopreneurs means testimonials won't resonate with future buyers.
Hidden assumption — "marketing managers at 10-50 person companies" is a reachable audience,
but these people don't self-identify that way.
Revised plan: run a $47 pilot with 20 people first to identify who actually shows up.
