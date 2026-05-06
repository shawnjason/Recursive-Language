-- ID 139: One-Sided Faithful Summary Gives Safe Abstention
--
-- Catalog ID 139 (Recursive Language Models paper).
-- Soundness-without-completeness consequence of the summary-state framework.
--
-- Statement: a summary-state decoder need not be both sound and complete
-- to support safe behavior. A sound-but-incomplete decoder — one whose
-- positive certifications are correct but whose negatives may be
-- conservative — still supports an abstention policy that achieves zero
-- non-admissible commitments. The policy commits only to actions the
-- decoder positively certifies; otherwise it abstains. Safety is
-- preserved at the cost of productivity (some admissible actions are
-- declined). This is the structural basis for safe-abstention RLM
-- deployments: a one-sided faithful summary is sufficient for safety,
-- even though full extendability preservation requires soundness and
-- completeness together.
--
-- Corresponds to Section 6 of:
--   "Recursive Language Models Through the Admissibility-Dynamics
--    Framework: A Principled Theory of When Recursive Scaffolding
--    Succeeds"
--
-- Shawn Kevin Jason

import Mathlib.Tactic
import Mathlib.Data.Set.Basic

variable {Prefix Action Summary : Type*}

/-- A sound decoder: every action the decoder positively certifies is
    actually admissible. The converse — that every admissible action is
    certified — is not required (the decoder may be incomplete). -/
def SoundDecoder
    (decode : Summary → Action → Prop)
    (σ : Prefix → Summary)
    (admissible : Prefix → Action → Prop) : Prop :=
  ∀ (p : Prefix) (u : Action), decode (σ p) u → admissible p u

/-- An abstention policy: at each prefix, the policy either commits to an
    action the decoder certifies or abstains. Encoded as Option Action
    where None denotes abstention. -/
def AbstentionPolicy (Summary Action : Type*) : Type _ := Summary → Option Action

/-- A safe abstention policy: every action the policy commits to is
    certified by the decoder. Abstention (None) is always safe. -/
def SafeAbstention
    (π : AbstentionPolicy Summary Action)
    (decode : Summary → Action → Prop) : Prop :=
  ∀ (s : Summary) (u : Action), π s = some u → decode s u

/-- Sound decoders support safe-abstention policies: any policy that
    commits only to decoder-certified actions makes only admissible
    commitments. The proof is direct: soundness means certified ⊆
    admissible, so the policy's committed actions are all admissible. -/
theorem sound_decoder_yields_safe_abstention
    (decode : Summary → Action → Prop)
    (σ : Prefix → Summary)
    (admissible : Prefix → Action → Prop)
    (π : AbstentionPolicy Summary Action)
    (h_sound : SoundDecoder decode σ admissible)
    (h_safe : SafeAbstention π decode) :
    ∀ (p : Prefix) (u : Action), π (σ p) = some u → admissible p u := by
  intro p u hcommit
  have hdec : decode (σ p) u := h_safe (σ p) u hcommit
  exact h_sound p u hdec

/-- Safe abstention is achievable: the always-abstain policy (constantly
    None) trivially satisfies SafeAbstention. The structural existence
    of a safe abstention policy does not require any decoder properties
    beyond consistency. -/
theorem always_abstain_is_safe
    (decode : Summary → Action → Prop) :
    SafeAbstention (fun _ : Summary => (none : Option Action)) decode := by
  intro s u hcommit
  simp at hcommit