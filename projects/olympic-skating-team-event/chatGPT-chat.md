

# GPT's thing

Treat each *segment* (short / rhythm / free) as its own scoring opportunity, but constrain selection so teams can’t magically field an unlimited set of skaters. Below I give a small, usable specification: a parameterized algorithm plus a precise integer-program formulation (so it’s exact) and a greedy heuristic (so it’s easy to run). Treat the ISU/IOC substitution limits as parameters you plug in to match the official rulebook.

---

# Problem statement (concise)

We score the same 10 NOCs that qualified for the team event. For each discipline (d) (Men, Women, Pairs, Dance) and for each segment (s) (short/rhythm, free), a team may use one of its actual skaters/teams who *skated that segment* in the individual competitions. Teams may use different skaters for short and free, subject to substitution/roster constraints. Points for each segment are assigned by ranking the 10 NOCs’ chosen skater placements and mapping to the 10→1 points scale (1st→10, 2nd→9, …, 10th→1). Sum points over all 8 segments (4 disciplines × 2 segments) to get team totals.

---

# Inputs you must collect

* The 10-team list for that Olympics.
* For each discipline (d) and segment (s): the ordered list of actual skaters/teams and their **segment placement** in the individual event (i.e., short program placement / free skate placement and whether they actually skated).
* For each NOC (n) and discipline (d): the roster of skaters/teams that are eligible/entered in that discipline (those who could be used).
* A substitution budget rule (parameter): the maximum number of **distinct** skaters/teams a given NOC may use across the two segments of a discipline (call it (B_{n,d})). Also optionally a global roster-size limit per discipline (R_{n,d}). (Set these to match ISU rules.)

If you want the official substitution caps, those are in the ISU/Olympic technical rules — plug them in. If you don’t know them, choose a sensible default (e.g. (B_{n,d}=2) allowing one substitute between short and free).

---

# Exact formulation (0/1 integer program)

Indices:

* (n) ∈ NOCs (the 10)
* (d) ∈ disciplines (4)
* (s) ∈ segments (short/rhythm=1, free=2)
* (k) ∈ roster members of NOC (n) in discipline (d) who actually skated segment (s)

Decision variables:

* (x_{n,d,s,k} \in {0,1}) — 1 if NOC (n) uses skater (k) for discipline (d), segment (s).

Constraints:

1. Exactly one representative per NOC per (d,s):
   [
   \sum_{k} x_{n,d,s,k} = 1 \quad\forall n,d,s
   ]
   (If NOC had no skater who skated that segment, allow them to choose “none” and treat as zero points; simpler: allow the variable set to be empty and treat sum=0 — then later disqualify NOCs with fewer than 3 disciplines present.)

2. Substitution/roster constraint — limit distinct skaters used across segments:
   [
   \sum_{k} y_{n,d,k} \le B_{n,d} \quad\forall n,d
   ]
   with
   [
   y_{n,d,k} \in {0,1},\quad y_{n,d,k} \ge x_{n,d,1,k},\quad y_{n,d,k} \ge x_{n,d,2,k}
   ]
   (so (y) indicates whether skater (k) is used in at least one segment; the sum of distinct skaters ≤ budget.)

3. Eligibility: (x_{n,d,s,k}) only exists if skater (k) actually skated segment (s) in the individual event.

Objective:

* Compute placement among the 10 NOCs for each (d,s) based on the chosen skater’s **segment placement** (lower placement = better). Translate those positions into points (p_{rank}\in{10,\dots,1}). Maximize total team points:
  [
  \max \sum_{n,d,s} p(\text{rank}_{n,d,s})
  ]
  (You can linearize (p(\text{rank})) by precomputing points for each possible skater (k) relative to other NOCs’ chosen skaters; in practice solving the IP with a solver is straightforward.)

This yields the optimal assignment of which actual skater to credit for each segment for every NOC given substitution caps.

---

# Greedy, easy-to-run heuristic (fast, near-optimal)

1. For every (n,d,s), identify the single skater (k^\star) with the best segment placement among that NOC’s available skaters who skated segment (s). Tentatively pick those.
2. For each (n,d) check distinct skaters used. If distinct count ≤ (B_{n,d}) keep; otherwise:

   * While distinct count > (B_{n,d}), find the segment whose current chosen skater is the *least marginally valuable* (i.e., swapping to the next-best available skater from the same NOC causes the smallest drop in segment points). Perform that swap. Repeat until within budget.
     This greedy swap is simple and will usually get the IP-optimal result because substitution budgets are tiny.

---

# Edge cases & rule details to decide

* If an NOC did not have any skater in a segment: treat as 0 points for that segment (same as official team event). Make teams with fewer than 3 disciplines present ineligible if you want strict parity with Olympic eligibility.
* Ties in segment placement: use ISU tie-break (higher segment score), or break ties by total segment points — be explicit.
* Whether to score segments equally (short vs free): the official team event weights short and free differently (short is used in qualifying). If you want to replicate the official spirit exactly, apply the official segment-point mapping; otherwise treat both as equal. (Recommendation: use equal segment points so every skated segment contributes.)

---

# Practical notes

* This is easy to implement in a few dozen lines of Python with Pandas + a small ILP solver (e.g., `pulp` or `ortools`) — or just the greedy heuristic if you want fast retroactive tables.
* If you want, I can implement the greedy version for the 2018 NOCs you listed and show the resulting podiums. If you want exact compliance with ISU substitution limits, I’ll need those rule numbers (I can fetch them).

---

If you want the IP formulation translated into runnable Python code (pulp/ortools) or a ready spreadsheet layout, tell me which and I’ll generate it.
