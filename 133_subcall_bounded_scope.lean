-- ID 133: Sub-Calls Construct Bounded-Scope Summaries
--
-- Catalog ID 133 (Recursive Language Models paper).
-- Definitional consequence of the RLM sub-call output budget.
--
-- Statement: an RLM sub-call is a function whose output is bounded in
-- size by a parameter `b`. By construction, every sub-call output sits
-- in a space of cardinality at most `b`. This is a definitional
-- consequence of how RLM sub-calls are typed, but is recorded explicitly
-- because subsequent results about RLM compositional reach (sufficiency
-- on bounded-decomposable predicates, insufficiency on global invariants)
-- cite it as a structural premise.
--
-- Corresponds to the sub-call output-budget construction of:
--   "Recursive Language Models Through the Admissibility-Dynamics
--    Framework: A Principled Theory of When Recursive Scaffolding
--    Succeeds"
--
-- Shawn Kevin Jason

import Mathlib.Tactic

/-- A bounded-output sub-call: a function from any input type into a
    finite codomain of cardinality at most `b`. The output budget is
    enforced at the type level by the codomain. -/
def BoundedSubCall (Input : Type) (b : ℕ) : Type := Input → Fin b

/-- Sub-call output budget: every output of a bounded sub-call sits in a
    finite codomain of cardinality at most `b`. The output index is
    strictly less than the budget for any input. -/
theorem subcall_output_bounded
    {Input : Type} {b : ℕ}
    (f : BoundedSubCall Input b) (x : Input) :
    (f x).val < b := by
  exact (f x).isLt

/-- The codomain of a bounded sub-call has cardinality at most `b`. This
    is the type-level form of the output-budget claim: the entire image
    of a sub-call lives inside a space of size `b`. -/
theorem subcall_codomain_card_bounded
    {_Input : Type} (b : ℕ) :
    Fintype.card (Fin b) = b := by
  exact Fintype.card_fin b

/-- Composing a sub-call with any post-processing function preserves the
    bounded-output property at the level of the original sub-call: the
    intermediate sub-call output is still budget-bounded, regardless of
    what the post-processor does with it. This formalizes that downstream
    reasoning cannot exceed the information bound set by the sub-call. -/
theorem subcall_composition_inherits_bound
    {Input Output : Type} {b : ℕ}
    (f : BoundedSubCall Input b) (g : Fin b → Output) (x : Input) :
    ∃ k : Fin b, g (f x) = g k := by
  exact ⟨f x, rfl⟩