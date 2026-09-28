# Kingdom newspaper

Jonathan lock (2026-09-22): fiction/UI spine for **public** atelier news.

The newspaper is how the kingdom hears about your shop — not a separate meta system.

## What prints

| Moment | Newspaper beat |
|---|---|
| **Chapter start** | Boss **announcement** (drawn from chapter pool) — front page threat |
| **Mid-mission fail** | Scandal / flop **headline** (rating D/F or death) |
| **Mid-mission clear S/A** | Optional praise blurb (Later; Phase-1 can skip) |
| **Chapter end** | Chapter **result** — boss clear, reps gate miss, or boss death |
| **Run over** | Final edition — shop ruined / adventurer lost |

Letters (`23`) stay private (client → you). Newspaper is **public** reputation fiction tied to reps (`25`).

## Phase-1 UI

- One reusable newspaper frame (placeholder art OK).
- Slots: masthead, headline, subhead (boss tags / mission name), optional woodcut (Later).
- Opening a chapter = open newspaper to the boss announce edition, then dismiss into atelier.

## Stamp / Client

```
newspaper_event: boss_announce | mid_fail | chapter_result | run_over
newspaper_headline_id: string
```

Design fills headline copy tables Later; ids stable for harness.
