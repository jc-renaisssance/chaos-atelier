# Core loop

## Chapter loop (StS-style — Jonathan lock)

1. **Chapter start:** the **chapter boss is announced** (name / threat tags / environment). Player sees the target before spending.
2. **Shop** (meets a **shop owner** — Phase-1 = basic clerk only) → reshape material deck (buy / sell / sparse remove) or buy a **skill** if a skill-owner appears (Later).
3. **Craft & task** — take clients / side tasks; each yields gold, mats, info; craft gear toward the announced boss.
4. **Shop** again (and repeat shop → craft/task → shop) until the chapter clock / node count ends.
5. **Boss fight** with the prepared deck + crafted gear.
6. Next chapter (harder boss announced at its start).

Goal: player **adjusts the deck** through the chapter cycle knowing the boss, like Slay the Spire act bosses. Different owners (Later) change what the shop can offer — like Balatro shop variants.

## Single client beat (inside craft & task)

1. **Client** arrives with a clear threat (enemy + environment).
2. Select **materials** from deck (budget / hand limited; **multi-stack** into construction slots).
3. Combine **Construction + 1..N Materials + 0..1 Enchantment**.
4. Gear gets **stats + powers** (positive and **negative** synergies) from the resolver; **outlook** = highest `outlook_order` (negs included).
5. **Adventure simulation** — short report (tags / powers / outlook).
6. **Result** → gold, materials, reputation; scars Later.

## Phase-1 ship spine

Ship **one loop UI**: client brief → craft → adventure report → shop (`own_basic`), with **chapter boss known at chapter start** even if full act map is stubbed.

Defer encyclopedia depth, special clients, multi-owner shops, and parallel meta until that holds.
