-- ID 145: Runtime Recursion Must Be Measured, Not Merely Enabled
--
-- Catalog ID 145 (Recursive Language Models paper).
-- Structural distinction between configured and runtime recursion depth.
--
-- Statement: an RLM architecture's configured maximum recursion depth
-- d_max is an upper bound on permitted sub-call nesting, not a guarantee
-- that any specific execution reaches that depth. The actual runtime
-- depth on a given query is a property of the execution trace and must
-- be measured per-execution. A policy that returns at shallow depths
-- effectively behaves like a shallower architecture on those queries,
-- even though deeper recursion is permitted by configuration.
-- Therefore claims about RLM reach must be conditioned on the actual
-- runtime depth used, not merely on the configured maximum.
--
-- Corresponds to Section 5 / depth-measurement caveat of:
--   "Recursive Language Models Through the Admissibility-Dynamics
--    Framework: A Principled Theory of When Recursive Scaffolding
--    Succeeds"
--
-- Shawn Kevin Jason

import Mathlib.Tactic

/-- An execution trace's runtime recursion depth. Bounded above by the
    configured d_max but not in general equal to it. -/
def RuntimeDepth (Trace : Type*) := Trace → ℕ

/-- The configured maximum: every execution stays at or below d_max. -/
def WithinConfiguredBound
    {Trace : Type*} (depth : RuntimeDepth Trace) (d_max : ℕ) : Prop :=
  ∀ t : Trace, depth t ≤ d_max

/-- Configured-vs-runtime separation witness: there exists an execution
    trace whose runtime depth is strictly less than the configured maximum.
    Encoding: for any d_max ≥ 1, the existence of a trace at depth 0
    (immediate return without recursion) is the witness. -/
theorem configured_does_not_force_runtime
    (d_max : ℕ) (h_pos : 1 ≤ d_max) :
    ∃ (Trace : Type) (depth : RuntimeDepth Trace) (t : Trace),
      WithinConfiguredBound depth d_max ∧ depth t < d_max := by
  refine ⟨Unit, fun _ => 0, (), ?_, ?_⟩
  · intro _
    exact Nat.zero_le _
  · exact h_pos

/-- Runtime depth is not determined by configured depth alone: there exist
    architectures with the same configured d_max but different runtime
    depth distributions. -/
theorem runtime_depth_underdetermined_by_config
    (d_max : ℕ) (h_pos : 1 ≤ d_max) :
    ∃ (Trace : Type) (depth1 depth2 : RuntimeDepth Trace),
      WithinConfiguredBound depth1 d_max ∧
      WithinConfiguredBound depth2 d_max ∧
      ∃ t : Trace, depth1 t ≠ depth2 t := by
  refine ⟨Unit, (fun _ => 0), (fun _ => d_max), ?_, ?_, ⟨(), ?_⟩⟩
  · intro _; exact Nat.zero_le _
  · intro _; exact Nat.le_refl _
  · show (0 : ℕ) ≠ d_max
    omega

/-- Reach claims must be conditioned on runtime depth: even when d_max is
    configured, the actual reach class achievable on a specific query
    depends on the runtime depth used, which is a separate measured
    quantity. The configured bound is a permission, not a guarantee. -/
theorem reach_must_condition_on_runtime_depth
    (d_max : ℕ) (h_pos : 1 ≤ d_max) :
    ∃ (Trace : Type) (depth : RuntimeDepth Trace),
      WithinConfiguredBound depth d_max ∧
      ¬ (∀ t : Trace, depth t = d_max) := by
  refine ⟨Unit, (fun _ => 0), ?_, ?_⟩
  · intro _; exact Nat.zero_le _
  · intro h
    have := h ()
    simp at this
    omega