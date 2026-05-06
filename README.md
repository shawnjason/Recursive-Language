# Recursive Language Models — Lean Proofs

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20060154.svg)](https://doi.org/10.5281/zenodo.20060154)

Machine-checked Lean 4 proofs for:

**"Recursive Language Models Through the Admissibility-Dynamics Framework: A Principled Theory of When Recursive Scaffolding Succeeds"**

Paper DOI (concept, always resolves to latest): [10.5281/zenodo.19753549](https://doi.org/10.5281/zenodo.19753549)

---

## Author

Shawn Kevin Jason — Independent Researcher, Las Vegas, NV
ORCID: [![ORCID iD](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0009-0003-9208-1556) [0009-0003-9208-1556](https://orcid.org/0009-0003-9208-1556)

---

## What This Repository Contains

Six standalone Lean 4 proof files covering the principal formal results of the paper. The proofs split into four groups: an **architectural primitives** group establishing that RLM sub-call outputs are type-bounded by the per-call budget; a **sufficient conditions** group covering the three structural properties under which RLM deployments achieve bounded inconsistency (sound-decoder safe abstention, bounded-decomposable predicates that admit sub-check certification, and runtime recursion depth verified per execution rather than merely permitted by configuration); a **class closure under training** group establishing that training within a fixed architectural `(d, b)`-class cannot extend reach beyond the class's information bound; and a **deployment synthesis** group establishing the constraint-requirement disjunction that any uniformly-bounded-inconsistency RLM deployment must satisfy.

Each file is independent and verifies against the current Mathlib release.

---

## Files

### Architectural Primitives

**`133_subcall_bounded_scope.lean`** — Sub-Calls Construct Bounded-Scope Summaries
Definitional consequence of how RLM sub-calls are typed: an RLM sub-call is a function whose output is bounded in size by a parameter `b`, so every sub-call output sits in a space of cardinality at most `b`. Recorded explicitly because subsequent results about RLM compositional reach (sufficiency on bounded-decomposable predicates, insufficiency on global invariants) cite it as a structural premise. The file proves the output bound, the codomain cardinality bound, and that composition of sub-calls inherits the bound.

### Sufficient Conditions for Bounded Inconsistency

**`139_sound_decoder_safe_abstention.lean`** — Sound Decoder Safe Abstention
Soundness-without-completeness consequence of the summary-state framework: a summary-state decoder need not be both sound and complete to support safe behavior. A sound-but-incomplete decoder — one whose positive certifications are correct but whose negatives may be conservative — still supports an abstention policy that achieves zero non-admissible commitments. The policy commits only to actions the decoder positively certifies and otherwise abstains. Safety is preserved at the cost of productivity. This is the structural basis for safe-abstention RLM deployments and the first of three conditions the deployment synthesis disjunction packages.

**`143_rlm_rag_architectural_contrast.lean`** — RLM / RAG Architectural Contrast (escape and inheritance directions)
Two-sided characterization of where RLM extends RAG and where it doesn't, in a single file. The escape direction (`rlm_escapes_rag_on_bounded_decomposable`): on admissibility predicates that factor into bounded-scope sub-checks, RLM's recursive sub-call structure can certify admissibility through composition of sub-check certificates, where standard RAG's single-shot retrieval cannot. The inheritance direction (`rlm_inherits_rag_insufficiency_on_non_decomposable`): on global invariants that do not factor into bounded-scope sub-checks, RLM's recursive structure does not escape the obstruction — no sub-call's bounded-budget output captures the non-decomposable global condition. The fault line between the two regimes is the `BoundedDecomposable` predicate; the escape direction is the second of three sufficient conditions for bounded-inconsistency deployment.

**`145_runtime_recursion_must_be_measured.lean`** — Runtime Recursion Must Be Measured, Not Merely Enabled
Structural distinction between configured and runtime recursion depth: an RLM architecture's configured maximum recursion depth `d_max` is an upper bound on permitted sub-call nesting, not a guarantee that any specific execution reaches that depth. The actual runtime depth on a given query is a property of the execution trace and must be measured per-execution. Three theorems formalize the consequence — configured depth does not force runtime depth, runtime depth is underdetermined by configuration, and reach claims must condition on the actual runtime depth used. Per-execution depth verification is the third of three sufficient conditions for bounded-inconsistency deployment.

### Class Closure Under Training

**`148_training_preserves_reach.lean`** — Training Cannot Extend RLM Reach Beyond Information Bound
Class-closure consequence: an RLM architecture with fixed depth `d` and per-call budget `b` has a structural information bound determined by `(d, b)`. Training is a transformation that updates policy parameters within the `(d, b)`-class but does not change the architectural information bound. Therefore training cannot produce a `(d, b)`-RLM that solves a query the class as a whole cannot solve. The file establishes that training preserves unreachability and that no training scheme extends the reach of the architectural class.

### Deployment Synthesis

**`149_constraint_requirement_boundary.lean`** — Constraint-Requirement Boundary for RLM Deployments
Synthesis of the architectural results into a deployment-level claim: an RLM deployment that claims uniformly bounded inconsistency across queries must satisfy at least one of three structural conditions — (a) the admissibility predicates lie in the bounded-decomposable class (so sub-call composition certifies admissibility, per `143_rlm_rag_architectural_contrast.lean`); (b) the deployment incorporates a sound decoder supporting safe abstention (so non-admissible commitments are excluded by conservative refusal, per `139_sound_decoder_safe_abstention.lean`); or (c) the runtime recursion depth on every query is measured and verified to meet the architectural reach requirement (per `145_runtime_recursion_must_be_measured.lean`). A deployment satisfying none of these inherits RAG-like insufficiency on non-decomposable predicates and provides no uniform inconsistency guarantee.

---

## Mapping to the Paper

| Paper Result | File | Lean Theorem |
|---|---|---|
| Sub-Calls Construct Bounded-Scope Summaries | `133_subcall_bounded_scope.lean` | `subcall_output_bounded`, `subcall_codomain_card_bounded`, `subcall_composition_inherits_bound` |
| Sound Decoder Safe Abstention | `139_sound_decoder_safe_abstention.lean` | `sound_decoder_yields_safe_abstention`, `always_abstain_is_safe` |
| RLM / RAG Architectural Contrast (escape + inheritance directions) | `143_rlm_rag_architectural_contrast.lean` | `rlm_escapes_rag_on_bounded_decomposable`, `rlm_inherits_rag_insufficiency_on_non_decomposable`, `rlm_rag_fault_line` |
| Runtime Recursion Must Be Measured | `145_runtime_recursion_must_be_measured.lean` | `configured_does_not_force_runtime`, `runtime_depth_underdetermined_by_config`, `reach_must_condition_on_runtime_depth` |
| Training Cannot Extend RLM Reach | `148_training_preserves_reach.lean` | `training_preserves_unreachability`, `no_training_extends_reach` |
| Constraint-Requirement Boundary for RLM Deployments | `149_constraint_requirement_boundary.lean` | `constraint_requirement_satisfiable`, `any_branch_satisfies_constraint_requirement` |

---

## How to Verify

1. Open [live.lean-lang.org](https://live.lean-lang.org)
2. Confirm the dropdown in the upper right is set to **Latest Mathlib**
3. Paste the contents of any `.lean` file into the editor
4. Wait for checking to complete — "No goals" on each theorem and no errors in the Problems pane confirms verification

Each file is independent; no cross-file imports are required.

---

## Scope

These proofs verify the formal logical structure of the principal results: the architectural primitives, the three sufficient conditions for bounded-inconsistency RLM deployment, the class-closure consequence under training, and the deployment-boundary synthesis. They do not establish:

- The RLM Insufficiency Theorem itself, which is developed in the associated paper; the formalization in `148_training_preserves_reach.lean` covers its contrapositive — that training within the `(d, b)`-class cannot extend reach beyond the class's information bound
- The empirical analysis applying the framework's predictions to published RLM benchmark data, reported separately
- The framework-level conjectures and open claims listed alongside the formalized theorems

---

## Related Work

The foundational projection-theoretic result underlying the framework is developed in:

*Projection Insufficiency and Trajectory Realization: A Unified Constraint-Based Framework for Bounded Systems* — [DOI: 10.5281/zenodo.19633241](https://doi.org/10.5281/zenodo.19633241) (Lean proofs: [10.5281/zenodo.19687629](https://doi.org/10.5281/zenodo.19687629))

The forward-case impossibility result establishing the divergence kernel and arithmetic-witness machinery is developed in:

*The Non-Locality of Extendability: An Impossibility Theorem for Bounded Information Systems, with Applications to Generative Sequential Systems* — [DOI: 10.5281/zenodo.19688367](https://doi.org/10.5281/zenodo.19688367) (Lean proofs: [10.5281/zenodo.19687799](https://doi.org/10.5281/zenodo.19687799))

The stochastic extension establishing the admissibility-dynamics framework on which this paper builds is developed in:

*Inconsistency Accumulation in Forward-Local Sequential Policies: A Lower Bound under Delayed Constraints* — [DOI: 10.5281/zenodo.19688628](https://doi.org/10.5281/zenodo.19688628) (Lean proofs: [10.5281/zenodo.19687094](https://doi.org/10.5281/zenodo.19687094))

The language-model specialization providing the structural-ceiling and certification-depth context for bounded-context generative systems is developed in:

*Language Model Hallucinations: An Impossibility Theorem and Its Architectural Consequences* — [DOI: 10.5281/zenodo.19715059](https://doi.org/10.5281/zenodo.19715059) (Lean proofs: [TBD](https://doi.org/TBD))

---

## License

MIT
