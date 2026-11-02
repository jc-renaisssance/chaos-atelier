# M2 production baseline

**Status:** Automated baseline established 2026-11-02 against Godot **4.7.2 stable** and `dev` after `c4f5794`. M2 content-boundary follow-up landed in the worktree the same day: live new runs use `map_m2_demo`; `map_m1` remains regression. This is validation evidence, not a gameplay or balance stamp.

## Purpose

This baseline is the first task in the M2 production roadmap. It answers whether the current project can import, boot, traverse its complete chapter state machine, preserve a run, export for Windows, and boot that export before production gameplay changes begin.

## Reproducible commands

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run_m2_smoke.ps1
powershell -ExecutionPolicy Bypass -File .\tools\export_windows_debug.ps1
```

Both scripts accept `-GodotPath <path>` when Godot is installed elsewhere. Smoke and export validation redirect `APPDATA` into `.godot/` so automated runs do not use the player's real `user://` save.

## Automated baseline result

| Check | Result |
|---|---|
| Headless project import | PASS |
| Main-scene boot | PASS |
| Six player scenes load and instantiate | PASS |
| M1/M2 pools remain disjoint | PASS |
| M2 roster | PASS — 4 jobs, 12 named adventurers |
| M2 route boundary | PASS — every `map_m2_demo` adventurer node is M2-only |
| Deterministic M2 draw sweep | PASS — 128 seeds, all four jobs covered |
| New run and boss newspaper | PASS |
| Harness schema at run start and terminal state | PASS |
| Save and continue round-trip | PASS — `map_id` preserved; old saves without it fall back to `map_m1` |
| Production affinity regression | PASS — per-item tiers, five formulas/mechanics, commitment, starter bolt, stamina, and six market skills |
| Complete chapter state traversal | PASS — route, market, event, order craft, playback, boss craft |
| One-fight law | PASS — per-piece vignettes followed by one combined fight |
| Windows debug export | PASS |
| Exported executable headless boot | PASS |

Reference smoke on 2026-11-02:

```text
M2_SMOKE PASS checks=587 elapsed_ms=2538 route_steps=48 vignettes=6 fights=3 terminal=run_over
```

The automated chapter intentionally finishes empty construction-only pieces. It raises reps to bypass the balance gate so the smoke reaches the live M2 boss draw, then accepts either chapter clear or boss-death as a legal terminal state. It proves state-flow integrity; it does not claim that an empty build is balanced to win.

## Export evidence

Preset: `Windows Desktop` in `export_presets.cfg`.

Generated under ignored `build/windows/`:

| File | Baseline size |
|---|---:|
| `Wombaste.exe` | 103,068,160 bytes |
| `Wombaste.console.exe` | 82,432 bytes |
| `Wombaste.pck` | 1,093,072 bytes |

The export excludes `tests/*`. The exported console wrapper completed a 120-frame headless boot without script errors.

## Visual inspection

A manual export smoke reached:

1. Title screen;
2. new-run route map and boss announcement;
3. D1 adventurer order;
4. two-zone craft screen with 24 stamina and a five-card hand;
5. Finish;
6. the first per-piece vignette.

No crash or blocking UI defect appeared in that path. This visual capture predates the affinity amend; the live two-item formula is now 18 stamina and awaits the next manual capture.

### Observed baseline gaps

- Playback posture art still falls back to an empty placeholder when a posture file is absent.
- The Client still uses the earlier long adventurer display strings; the Public names and identity reveals in [29](29-adventurer-catalog.md) are docs-only.
- The automated run establishes technical timing only. The 90-second contract, 8-minute Tie Off, comprehension, promise uptake, and 30–45 minute human-demo targets in [41](41-gameplay-experience-rework.md) still require external playtests.
- A debug export is reproducible. Store packaging, signing, Steam upload, and release-template validation are outside this baseline.

## Smoke coverage ownership

- Runner: `tests/m2_smoke.gd`
- Test scene: `tests/m2_smoke.tscn`
- Command wrapper: `tools/run_m2_smoke.ps1`
- Windows export wrapper: `tools/export_windows_debug.ps1`
- Export configuration: `export_presets.cfg`

Every production gameplay slice should keep this smoke green and add focused assertions when it changes the route, craft, persistence, playback, or boss state machine.
