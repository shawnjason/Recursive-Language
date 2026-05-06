-- ID 148: Training Cannot Extend RLM Reach Beyond Information Bound
--
-- Catalog ID 148 (Recursive Language Models paper).
-- Contrapositive consequence of RLM Insufficiency (catalog ID 137).
--
-- Statement: an RLM architecture with fixed depth d and per-call budget
-- b has a structural information bound determined by (d, b). The RLM
-- insufficiency theorem establishes that for any RLM in this class,
-- there exist queries with non-decomposable global invariants that the
-- RLM cannot solve. Training is a transformation that updates policy
-- parameters within the (d, b)-class but does not change the
-- architectural information bound. Therefore training cannot produce a
-- (d, b)-RLM that solves a query the class cannot solve. Training
-- improves performance within the reach class; it does not extend the
-- class itself.
--
-- Corresponds to the training-non-extension corollary of:
--   "Recursive Language Models Through the Admissibility-Dynamics
--    Framework: A Principled Theory of When Recursive Scaffolding
--    Succeeds"
--
-- Shawn Kevin Jason

import Mathlib.Tactic

variable {RLM Query : Type*}

/-- The reach class of an RLM architecture: the set of queries the RLM
    can solve. Encoded as a predicate `solves : RLM → Query → Prop`. -/
def Solves (solves : RLM → Query → Prop) (m : RLM) (q : Query) : Prop := solves m q

/-- An RLM insufficiency witness: a query that no RLM in the architectural
    class can solve. The RLM insufficiency theorem establishes the
    existence of such queries for any (d, b)-class with non-decomposable
    global invariants. -/
def UnreachableQuery (solves : RLM → Query → Prop) (q : Query) : Prop :=
  ∀ m : RLM, ¬ solves m q

/-- A training scheme: any transformation that maps RLMs within the
    architectural class. Training updates parameters but does not change
    the (d, b) structural bound, so it stays within the class. -/
def TrainingScheme (RLM : Type*) : Type _ := RLM → RLM

/-- Training cannot solve queries the architectural class cannot solve.
    For any training scheme T, if q is unreachable for the class, then
    no trained model T(m) solves q. The information bound is preserved
    under within-class transformations. -/
theorem training_preserves_unreachability
    (solves : RLM → Query → Prop) (q : Query)
    (h_unreach : UnreachableQuery solves q)
    (T : TrainingScheme RLM) :
    ∀ m : RLM, ¬ solves (T m) q := by
  intro m
  exact h_unreach (T m)

/-- Strict-extension impossibility: no training scheme produces an RLM
    that solves a query the architectural class cannot solve. Training
    cannot extend the reach class beyond the information bound determined
    by (d, b). -/
theorem no_training_extends_reach
    (solves : RLM → Query → Prop) (q : Query)
    (h_unreach : UnreachableQuery solves q) :
    ¬ ∃ (T : TrainingScheme RLM) (m : RLM), solves (T m) q := by
  rintro ⟨T, m, hsolve⟩
  exact h_unreach (T m) hsolve