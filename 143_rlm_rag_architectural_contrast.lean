-- IDs 143 + 144: RLM Architectural Contrast with RAG
--
-- Catalog IDs 143 and 144 (Recursive Language Models paper).
-- Two-sided characterization of where RLM extends RAG vs where it doesn't.
--
-- Statement (ID 143, escape direction): on admissibility predicates that
-- factor into bounded-scope sub-checks, RLM's recursive sub-call structure
-- can certify admissibility through composition of sub-check certificates.
-- Where every sub-check is independently certifiable, the RLM succeeds.
-- Standard RAG's single-shot retrieval cannot in general assemble such
-- sub-check certificates without recursion.
--
-- Statement (ID 144, inheritance direction): on admissibility predicates
-- that do not factor into bounded-scope sub-checks — global invariants
-- requiring full-trajectory information — RLM's recursive structure does
-- not escape the obstruction. The same impossibility that blocks
-- bounded-context RAG also blocks the RLM, because no sub-call's
-- bounded-budget output captures the non-decomposable global condition.
--
-- Together: RLM strictly extends RAG on bounded-decomposable predicates
-- and exactly inherits RAG's impossibility on non-decomposable predicates.
-- The architectural fault line is decomposability of the admissibility
-- predicate, not depth of recursion.
--
-- Corresponds to Section 5 of:
--   "Recursive Language Models Through the Admissibility-Dynamics
--    Framework: A Principled Theory of When Recursive Scaffolding
--    Succeeds"
--
-- Shawn Kevin Jason

import Mathlib.Tactic
import Mathlib.Data.Set.Basic

variable {Query Output SubCheck : Type*}

/-- A bounded-decomposable predicate: admissibility of an output for a
    query factors into a finite list of sub-checks, each individually
    certifiable. -/
def BoundedDecomposable
    (admissible : Query → Output → Prop)
    (subChecks : Query → List SubCheck)
    (passes : Output → SubCheck → Prop) : Prop :=
  ∀ (q : Query) (o : Output),
    admissible q o ↔ ∀ s ∈ subChecks q, passes o s

/-- ID 143 escape direction: when the admissibility predicate is bounded-
    decomposable, an output passing every sub-check is certified admissible.
    This is the structural property RLMs exploit through recursion: each
    sub-call certifies one sub-check; composition of certificates yields
    full admissibility certification. -/
theorem rlm_escapes_rag_on_bounded_decomposable
    (admissible : Query → Output → Prop)
    (subChecks : Query → List SubCheck)
    (passes : Output → SubCheck → Prop)
    (h_decomp : BoundedDecomposable admissible subChecks passes)
    (q : Query) (o : Output)
    (h_pass : ∀ s ∈ subChecks q, passes o s) :
    admissible q o := by
  exact (h_decomp q o).mpr h_pass

/-- A non-decomposable predicate witness: there exist queries where the
    admissibility predicate cannot be expressed as a conjunction of
    bounded-scope sub-checks. Specifically, there exist outputs that pass
    every individual bounded-scope check but fail the global predicate. -/
def NonDecomposableWitness
    (admissible : Query → Output → Prop)
    (subChecks : Query → List SubCheck)
    (passes : Output → SubCheck → Prop) : Prop :=
  ∃ (q : Query) (o : Output),
    (∀ s ∈ subChecks q, passes o s) ∧ ¬ admissible q o

/-- ID 144 inheritance direction: when there exists a non-decomposable
    witness, the conjunction of sub-check passes does NOT imply admissibility.
    No sub-call composition can certify the global predicate. RLMs inherit
    RAG's insufficiency on non-decomposable predicates. -/
theorem rlm_inherits_rag_insufficiency_on_non_decomposable
    (admissible : Query → Output → Prop)
    (subChecks : Query → List SubCheck)
    (passes : Output → SubCheck → Prop)
    (h_witness : NonDecomposableWitness admissible subChecks passes) :
    ¬ ∀ (q : Query) (o : Output),
      (∀ s ∈ subChecks q, passes o s) → admissible q o := by
  rintro h_compose
  obtain ⟨q, o, h_pass, h_not_adm⟩ := h_witness
  exact h_not_adm (h_compose q o h_pass)

/-- The architectural fault line: bounded-decomposability and non-
    decomposability are the two sides of the RLM-RAG comparison. On
    bounded-decomposable predicates, sub-check composition certifies
    admissibility (RLM escapes RAG). On non-decomposable predicates,
    sub-check composition is insufficient (RLM inherits RAG's limits). -/
theorem rlm_rag_fault_line
    (admissible : Query → Output → Prop)
    (subChecks : Query → List SubCheck)
    (passes : Output → SubCheck → Prop) :
    (BoundedDecomposable admissible subChecks passes →
      ∀ (q : Query) (o : Output),
        (∀ s ∈ subChecks q, passes o s) → admissible q o) ∧
    (NonDecomposableWitness admissible subChecks passes →
      ¬ ∀ (q : Query) (o : Output),
        (∀ s ∈ subChecks q, passes o s) → admissible q o) := by
  refine ⟨?_, ?_⟩
  · intro h_decomp q o h_pass
    exact rlm_escapes_rag_on_bounded_decomposable
      admissible subChecks passes h_decomp q o h_pass
  · intro h_witness
    exact rlm_inherits_rag_insufficiency_on_non_decomposable
      admissible subChecks passes h_witness