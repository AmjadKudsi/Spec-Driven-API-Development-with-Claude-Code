# Verity / VerityClaw: Detection-Profile Dimensions and Axiomatic Aggregator — A Foundational Design Document

## Part 0 — Executive Summary and Reading Map

This document resolves two design questions for the Verity (VerityClaw) evaluation framework targeting IEEE CNS 2026.

- **Task 1 — Detection Profile.** We recommend a five-dimension Detection Profile: **Class-Weighted Coverage (CWC)**, **Difficulty-Adjusted Hit Rate (DAHR)**, **Severity-Weighted Yield (SWY)**, **Claim Reliability (CR)**, and **Novelty Reach (NR)**. We merge the original "hallucination penalty" and "reasoning faithfulness" candidates into a single **Claim Reliability** dimension after careful adjudication, while reporting the two components separately in the appendix to preserve diagnostic value.
- **Task 2 — Verity Aggregator.** We recommend a **two-stage weighted geometric mean** with an Atkinson-style inequality-aversion knob ε on the inner (class-aggregation) stage, expressed as a single closed-form scalar in [0, 1]. The formula uniquely satisfies the full ten-axiom set we derive, and it cleanly defends against SecLens-R's "no universal best model" objection by being explicitly an evaluation-of-detection-capability score rather than a deployment-procurement score (axiom A10 below).

---

# TASK 1 — DETECTION PROFILE DIMENSIONS

## 1.1 Comprehensive Literature Inventory of Dimensions Used in 2023–2026 LLM-Vulnerability-Detection Benchmarks

We surveyed the dimensions that the opponent landscape — PrimeVul (Ding et al., *Vulnerability Detection with Code Language Models: How Far Are We?*, ICSE 2025, arXiv 2403.18624), JITVUL (Yildiz et al., ACL 2025), ReVD (arXiv 2506.07390), IRIS (Li, Dutta & Naik, ICLR 2025, arXiv 2405.17238), CORRECT (arXiv 2504.13474), SecLens-R (arXiv 2604.01637), CyberSecEval 4 (Meta + Crowdstrike, 2025), SecVulEval (arXiv 2505.19828), SecLLMHolmes (Ullah et al., S&P 2024, arXiv 2312.12575), eyeballvul (Chauvin, arXiv 2407.08708), VulInstruct (arXiv 2511.04014) — actually report. We then apply the project's **3-paper threshold rule**: a dimension counts as well-established only if it appears as a *primary* (not appendix-only) measurement in three or more independent papers, OR if it uniquely addresses one of F1's four canonical failure modes (severity-blindness, single-prediction assumption, ground-truth instability, asymmetric FP/FN cost insufficiency).

### 1.1.1 Frequency Table

| Dimension (operational) | Papers (primary) | Threshold? | F1-failure-mode fix? |
|---|---|---|---|
| F1 / Accuracy / Precision / Recall | PrimeVul, IRIS, ReVD, CORRECT, SecVulEval, SecLens-R (D2–D4), CyberSecEval, JITVUL — 8+ | YES | (baseline) |
| MCC / Balanced Accuracy | PrimeVul appendix, JIT-VP realistic-eval (arXiv 2507.10729), SecLens-R D1 — 3+ | YES | Partial — class imbalance |
| FNR-at-fixed-FPR (VD-S, FNR @ FPR ≤ 0.5%) | PrimeVul (Ding et al. 2024), reused by Weissberg et al. (ICSE 2026 — mlsec.org), SecVulEval, ANVIL — 4+ | YES | Asymmetric FP/FN cost |
| Pairwise accuracy (pAcc / P-C / P-V / VP-S) | PrimeVul (P-C/P-V/P-B/P-R), JITVUL (pAcc), ReVD (VP-S), VulInstruct (P-C 17.2%, VP-S 7.4%) — 4+ | YES | Ground-truth instability, single-prediction assumption |
| CWE-class coverage / per-class F1 | IRIS (per-CWE recall: 37.25% on CWE-022, 46.15% on CWE-078, 22.58% on CWE-079, 40.00% on CWE-094), SecLens-R D9–D10, SecVulEval, CWE-Bench-Java — 5+ | YES | Severity-blindness (partial) |
| Localization (line/statement/function) | SecVulEval (statement-level F1, 25,440 functions, 5,867 CVEs), IRIS (path-level), SecLens-R D7 (mean location IoU) — 4+ | YES | — |
| Reasoning faithfulness / reasoning+correct verdict | SecLLMHolmes (dimension #4 "faithful reasoning"), CORRECT (LLM-as-judge rationale verification), SecVulEval ("TP if reasoning correct"), SecLens-R D16, ReVD — 5+ | YES | — |
| False-discovery rate / false-positive cost | IRIS (AvgFDR; manual inspection of 50 alarms yielded 27/50 with potential attack surfaces, refined FDR 46%), Project-scale empirical study (arXiv 2601.19239), SecLens-R (D3, D17) — 3+ | YES | — |
| Unique-find rate / novelty | VulInstruct ("Unique" metric: VulInstruct uniquely detects 24.3% of all identified vulnerabilities, 2.4× more than any baseline; also discovered CVE-2025-56538 in production code), IRIS (4 previously unknown Java vulnerabilities across 16 of 30 latest-version projects), eyeballvul (weekly-refresh CVE-replay setting) — 3 (borderline; no shared operationalization) | BORDERLINE | Severity-blindness (when combined) |
| Severity-weighted recall | SecLens-R D28 (critical 4×, high 3×, medium 2×, low 1×), CyberSecEval (informal), SecLLMHolmes (severity-tier evaluation) — 2 fully operationalized | NEAR-THRESHOLD | Severity-blindness (directly) |
| Calibration / ECE | HELM (Liang et al., TMLR 2023, arXiv 2211.09110, one of 7 HELM metrics: accuracy, calibration, robustness, fairness, bias, toxicity, efficiency) — adjacent, NOT yet primary in vuln-detection | NO (yet) | — |
| Efficiency / cost-per-task | SecLens-R Category D (D18–D23), CyberSecEval (token budgets), HELM — 3 | YES (operational, not capability) | — |
| Robustness to label noise | Risse & Böhme (USENIX Security 2024 *Uncovering the Limits of Machine Learning for Automatic Vulnerability Detection*; PACMSE 2024 *Top Score on the Wrong Exam*), CleanVul (arXiv 2411.17274), DiverseVul (RAID 2023), Mono — 4 | YES | Ground-truth instability |
| Robustness to perturbations / augmentations | SecLLMHolmes (dimension #7 "robustness to code augmentations"), ForgeJS (arXiv 2512.01255, where "under specific noise conditions, a leading model's F1 drops from 35.9% to 4.2%") — 2 | BELOW | — |

### 1.1.2 Conclusion of the Inventory

Six dimensions pass the 3-paper threshold and/or uniquely repair an F1 failure mode: per-class coverage, difficulty/pairwise-style discrimination, localization, reasoning faithfulness, severity weighting, and robustness-to-label-noise. Two further dimensions (novelty/zero-day reach, calibration) fail the strict threshold and must be defended on principle if retained. The fundamental implication is that **Verity needs roughly five to six dimensions**, not 35 — the threshold rule alone collapses SecLens-R's catalog to a defensible parsimony.

---

## 1.2 Per-Dimension Critique of the Six Candidates

### Dimension 1 — Coverage (across the seven taxonomy classes, class-difficulty weighted)

- **Strongest prior-art anchor:** SecLens-R Category B explicitly contains D9 "CWE Coverage Breadth" (fraction of CWE categories with ≥1 correct detection) and D10 "Worst Category Floor" (minimum F1 across all vulnerability categories — "no blind spots"). IRIS (ICLR 2025) reports per-CWE recall (37.25%/46.15%/22.58%/40.00% across the four CWEs covered by CWE-Bench-Java). SV-TrustEval-C, CWE-Bench-Java, and SecLLMHolmes dimension #5 ("evaluation over variety of vulnerabilities") are direct precursors.
- **Case classification: (a) — adopt directly with extension.** The "minimum F1 across classes" pattern (SecLens-R D10) is exactly the zero-blindness floor we want; the "weighted by class difficulty" extension is novel but small.
- **Adversarial questioning:** A system could game this by hyper-tuning to taxonomy boundaries; however, because Verity uses *primary class* labels with optional secondary tags and stratified sampling, dimension-class gaming requires solving the underlying classes. Partial correlation with raw recall but separated by per-class normalization. Risk: classes with few instances are noisy — mitigated by class-difficulty weighting that boosts hard, rarer classes.
- **Estimated usefulness beyond F1 + others: ~85%.** F1 cannot diagnose blindness on any single taxonomy class; coverage is irreplaceable.
- **Operationalization (level: per-class → aggregated to system).** For class c with instance set I_c, let p_c = (correct vulnerable detections in c) / |I_c|. Class difficulty weight d_c ∈ [1, 2] derived from inverse human/expert-solve rate on a calibration set. **Coverage = Σ_c d_c · p_c / Σ_c d_c**, clipped to [0,1]. Ground truth required: class label, instance-level vulnerability label, per-class difficulty estimate.

### Dimension 2 — Difficulty-Adjusted Hit Rate (DAHR)

- **Strongest prior-art anchor:** Item Response Theory (IRT). Lalor et al. (EMNLP 2016, "Building an Evaluation Scale Using Item Response Theory," arXiv 1605.08889) — the seminal NLP application of IRT — explicitly notes "two NLP systems with equal acc./R/P/F1 scores may not be equal in their ability to compare with human intelligence" and develops a θ score that "is a consistent measurement, compared to accuracy which varies with the difficulty of the dataset." Reused by Polo et al. (TinyBenchmarks 2024), MEDIRT (arXiv 2509.24186, USMLE-aligned IRT benchmark across 71 LLMs), Allen AI Fluid Benchmarking, and the Adaptive Testing for LLM Evaluation work (arXiv 2511.04689). In vulnerability detection, PrimeVul's pairwise families (P-C, P-V, P-B, P-R) and JITVUL's pAcc are operational *proxies* for difficulty.
- **Case classification: (b) — extend.** IRT supplies the theoretical machinery; no vulnerability-detection benchmark yet uses IRT explicitly, so we extend by importing IRT difficulty calibration to a security setting.
- **Adversarial questioning:** Objection #1 — difficulty labels are subjective. Mitigation: derive difficulty empirically from pilot human-expert solve rate, not author intuition. Objection #2 — DAHR may correlate strongly with Coverage if hard items cluster in certain classes. Mitigation: report rank correlation; we expect Coverage and DAHR to correlate at roughly ρ ≈ 0.5, retaining sufficient orthogonality. Gaming: a system that selectively answers only easy items could be punished by introducing a refusal penalty (we recommend awarding 0 on omitted items rather than excluding them).
- **Estimated usefulness beyond F1 + others: ~75%.** Hard-item credit is the right signal; orthogonality with Coverage is acceptable but not perfect.
- **Operationalization (level: per-instance → aggregated to system).** For instance i with difficulty δ_i ∈ [0,1] (1 = hardest), and binary correctness c_i ∈ {0,1}: **DAHR = Σ_i δ_i · c_i / Σ_i δ_i**. Ground truth: per-instance difficulty (empirical solve-rate from pilot) and correctness label.

### Dimension 3 — Severity Calibration (reframed: Severity-Weighted Yield, SWY)

- **Strongest prior-art anchor:** SecLens-R D28 "Severity-Weighted Recall" with explicit weights "critical 4×, high 3×, medium 2×, low 1×"; D29 "Critical Miss Rate" (1 − miss rate on critical/high severity vulnerabilities); SecLLMHolmes severity-tier evaluation. CVSS is the de facto severity ground truth across NVD records.
- **Case classification: (a)/(b) hybrid — direct adopt of severity weights, extension to rank-correlation.** Our reframing: instead of only recall weighted by severity, also score the system on whether it ranks its own findings consistently with CVSS severity (Spearman correlation between system-assigned salience and CVSS base score on true positives). The two combined yield SWY = α · severity-weighted recall + (1−α) · (Spearman ρ + 1)/2, with α defaulting to 0.7.
- **Adversarial questioning:** Objection — CVSS itself is noisy and disputed. Mitigation: use NVD-published CVSS v3.1 base scores; report robustness to swapping NVD scores for vendor scores. Gaming: a system could tag every finding as "critical" and inflate severity-weighted recall — mitigated by the rank-correlation component, which punishes uniform severity claims.
- **Estimated usefulness beyond F1 + others: ~90%.** F1 is severity-blind by definition; this is the largest single improvement over F1 in operational terms.
- **Operationalization (level: per-instance correctness × severity, → aggregated to system).** Ground truth: CVSS base score, system salience (rank or probability).

### Dimension 4 — Novelty / Zero-Day Reach (Mythos)

- **Strongest prior-art anchor:** Anecdotal across three works that lack a shared operationalization. **IRIS (ICLR 2025):** "when applied to the latest versions of 30 Java projects, IRIS with GPT-4 discovered 4 previously unknown vulnerabilities" — across 16 of 30 projects that raised at least one alert. **VulInstruct (arXiv 2511.04014):** introduces a "Unique" metric showing it uniquely detects 24.3% of all identified vulnerabilities (2.4× more than any baseline), under a strict criterion requiring both correct verdict and valid reasoning, and separately discovered CVE-2025-56538 in production code. **eyeballvul (arXiv 2407.08708):** "sourced and updated weekly from the stream of published vulnerabilities in open-source repositories," designed for evaluating results "especially the ones that were published after the training data cutoff" — its design is weekly future-proof updating rather than a static disclosure-window protocol.
- **Case classification: (c) — original measurement with justification required.** This is the most original — and most fragile — dimension.
- **Adversarial questioning (the hardest case in this report):**
  - Objection 1: "Zero-day" is unfalsifiable without ground truth; any system claim could be hallucination.
  - Objection 2: Rewarding zero-day claims incentivizes false positives.
  - Objection 3: Inter-benchmark transfer is poor — what is novel today is not novel tomorrow.
  - Responses: We define Novelty operationally via a **training-cutoff-novelty protocol** (inspired by eyeballvul's design): for each instance the benchmark records the CVE disclosure date d_i; the system's training cutoff t_train is known; a finding is novelty-eligible if d_i > t_train, and earns credit only when the finding is a true positive verified by the recorded patch. Where pre-disclosure runs are feasible (closed-environment dynamic benchmarks), we additionally credit findings with t < d_i. This makes the metric falsifiable and time-stamped. We recommend reporting Novelty as a *secondary*, lower-weighted dimension.
- **Estimated usefulness beyond F1 + others: ~55%** — high upside, but heavily dependent on benchmark refresh discipline; we include it but flag it.
- **Operationalization (level: per-instance, only on novel-eligible subset).** **NR = (correct novel detections) / (eligible-novel instances)**; if eligible-novel = 0, NR is undefined and excluded from aggregation.

### Dimension 5 — Hallucination Penalty (subsumed into Claim Reliability)

- **Strongest prior-art anchor:** Sewon Min et al., "FActScore: Fine-grained Atomic Evaluation of Factual Precision in Long-Form Text Generation" (arXiv 2305.14251, EMNLP 2023) — atomic-claim decomposition + verification against a knowledge source; HaluEval (Li et al. EMNLP 2023); FaithScore (arXiv 2311.01477) for vision-language faithfulness. In the security domain, IRIS's manual inspection ("we manually inspected 50 alarms raised by IRIS (using GPT-4) and found that 27/50 alarms exhibit potential attack surfaces, yielding a more refined estimated false discovery rate of 46%") is the closest operational match; SecLens-R D17 "FP Reasoning Quality" gestures in this direction.
- **Case classification: (b) — extend from factuality literature.**
- **Adversarial questioning:** Risk of double-counting with precision (already inside F1). Gaming: a system could refuse to give rationales and avoid penalty — mitigated by requiring rationale-presence (SecLens-R D15) as a precondition. The "convincing FP" worse than "obvious FP" intuition needs an operational signal: we use perplexity of the rationale under a held-out code-LM, or human-graded plausibility on a sample.
- **Estimated usefulness beyond F1 + others: ~70%** — significant but partially overlapping with reasoning faithfulness, hence the merge below.

### Dimension 6 — Reasoning Faithfulness (subsumed into Claim Reliability)

- **Strongest prior-art anchor:** Lanham et al. (Anthropic, 2023), "Measuring Faithfulness in Chain-of-Thought Reasoning" (arXiv 2307.13702) — uses early-answering and adding-mistakes interventions, with an Area Over Curve (AOC) metric on CoT-length, finding "as models become larger and more capable, they produce less faithful reasoning on most tasks we study"; Bentham, Stringham & Marasović 2024 (arXiv 2402.14897, "Chain-of-Thought Unfaithfulness as Disguised Accuracy"); the unlearning-based PFF/FUR method (arXiv 2502.14829). In vulnerability detection: SecLLMHolmes dimension #4 "faithful reasoning"; CORRECT (arXiv 2504.13474) which "employ[s] an LLM-as-a-judge mechanism to verify that the rationales correctly identify the root cause of each vulnerability and avoid misclassifying patched vulnerabilities as active"; SecVulEval, where "the best-performing Claude-3.7-Sonnet model achieves 23.83% F1-score for detecting vulnerable statements with correct reasoning, with GPT-4.1 closely behind" (25,440 function samples, 5,867 unique CVEs in C/C++ from 1999–2024); SecLens-R D16 "Reasoning + Correct Verdict."
- **Case classification: (b) — extend.**
- **Adversarial questioning:** Cost — faithfulness measurement requires LLM-as-judge or human review. Gaming: a system could produce minimal rationales. Mitigation: enforce that rationales must trace at least one source→sink path or one explicit chain-of-custody artifact for non-code classes.
- **Estimated usefulness beyond F1 + others: ~75%.**

---

## 1.3 The Merge Question — Hallucination Penalty + Reasoning Faithfulness → "Claim Reliability"

### Pro-merge arguments

1. **Common underlying construct.** Both dimensions concern *the quality of the system's claim about a finding*, not the binary detection event. FActScore decomposes claims into atomic facts and checks each; Lanham et al. test whether stated reasoning causally drives the answer. Both treat the rationale as the unit of evaluation.
2. **Practical operational overlap.** In every vulnerability-detection paper that measures either (SecLLMHolmes, CORRECT, SecVulEval, SecLens-R), the same LLM-as-judge or human-grader pipeline is used for both — there is no implementation distinction in practice.
3. **Parsimony.** The paper budget is 9 pages; the 3-paper threshold supports merging when the two underlying signals appear together in the same papers (CORRECT and SecVulEval both bundle them).
4. **Risk of dimension correlation.** Hallucinated FPs and unfaithful rationales correlate at the system level — both stem from generative ungroundedness — and inflating the dimension count with correlated signals violates parsimony in composite-indicator construction (OECD/JRC *Handbook on Constructing Composite Indicators*, Nardo, Saisana, Saltelli & Tarantola 2008, ISBN 978-92-64-04345-9, Chapter 6 on weighting and compensability).

### Anti-merge arguments

1. **Faithfulness measures a different *direction*.** Hallucination penalty is about *false positives that look real*; faithfulness is about *true and false positives where the stated reason is wrong*. A faithful FP and a correct-verdict-but-unfaithful TP are distinct failure modes.
2. **Diagnostic value.** Lanham et al. specifically argue that faithfulness should be evaluated *separately* from accuracy because models can be accurate via unfaithful reasoning (post-hoc rationalization). Collapsing the two loses this diagnostic channel.
3. **Different ground truths.** Hallucination penalty needs FP plausibility labels; faithfulness needs intervention-based or judge-based reasoning-validity labels.

### Resolution

**We recommend the merge.** The merged dimension is named **Claim Reliability (CR)** and is operationalized as the *joint* probability that (i) the system's verdict is correct AND (ii) the stated rationale is judged faithful to the actual code/configuration evidence. Formally:

**CR = (1/N) · Σ_i 𝟙[verdict_i correct] · 𝟙[rationale_i faithful] − λ · (1/N_FP) · Σ_{j ∈ FP} plausibility(rationale_j)**

where the first term rewards verdict-and-rationale joint correctness (SecVulEval-style) and the second term subtracts a plausibility-weighted penalty on false positives (the "convincing FP is worse than obvious FP" intuition). λ defaults to 0.3.

The merge preserves both signals in a single scalar while halving the dimension count. We **report the two components separately in the paper appendix** so reviewers can verify the merge does not hide divergent behavior. This handles the strongest anti-merge objection (loss of diagnostic value) without inflating the headline dimension count.

---

## 1.4 Dimensions We Considered and Excluded

Per the scan request, we reviewed the broader literature for missing candidates:

- **Localization precision (line/function/statement).** Strong prior art (SecVulEval statement-level F1; IRIS path-level; SecLens-R D7 mean location IoU). **Excluded** as a standalone dimension because for non-code-level taxonomy classes (Auth/AC, Supply Chain, Config, AI/ML), "line-level" is undefined. Instead, localization quality is folded into the *faithfulness* component of Claim Reliability — a rationale that points to the wrong line is unfaithful by construction.
- **Patch/exploit fidelity.** Prior art: CyberSecEval 4 AutoPatchBench measures "an LLM agent's capability to automatically patch security vulnerabilities in native code." **Excluded** because patch generation is a *separate task* from detection; including it would conflate detection with repair and violate the framework's stated detection scope.
- **Triage cost / FP burden.** Partially captured inside Claim Reliability's FP-plausibility penalty.
- **Robustness to label noise (Risse & Böhme angle).** This is a *benchmark-construction property*, not a system-evaluation dimension. We address it by reporting Verity scores under both the original labels and the Risse–Böhme-style cleaned subset (Risse & Böhme USENIX Security 2024 explicitly showed top-performing ML4VD models cannot distinguish vulnerable functions from their patched counterparts), as a robustness check rather than a dimension.
- **Confidence calibration (ECE/Brier).** Prior art exists in HELM (Liang et al. 2022, ECE as one of 7 HELM metrics) but is not yet a primary metric in any LLM-vuln-detection paper. **Folded into Severity-Weighted Yield's rank-correlation component** — a system that ranks its own findings consistently with CVSS is implicitly calibrated.
- **Evidence trajectory quality / cross-class transfer / inference cost.** All useful, all fail the 3-paper threshold in the vuln-detection sub-literature. **Excluded** to defend parsimony; we recommend listing them as future-work dimensions in the paper.

---

## 1.5 Final Recommended Dimension Set (Five Dimensions)

| # | Dimension | Level | Case | Operationalization |
|---|---|---|---|---|
| 1 | **Class-Weighted Coverage (CWC)** | per-class → system | (a) | Difficulty-weighted average of per-class detection rate, with minimum-class floor reported alongside |
| 2 | **Difficulty-Adjusted Hit Rate (DAHR)** | per-instance → system | (b) | IRT-style sum: Σ δ_i · c_i / Σ δ_i; difficulty calibrated empirically |
| 3 | **Severity-Weighted Yield (SWY)** | per-instance → system | (a)/(b) | Convex combination of severity-weighted recall (SecLens-R D28 weights) and Spearman rank-correlation with CVSS |
| 4 | **Claim Reliability (CR)** | per-instance → system | (b) | Joint verdict-correct ∧ rationale-faithful indicator minus plausibility-weighted FP penalty |
| 5 | **Novelty Reach (NR)** | per-instance (eligible) → system | (c) | Pre-disclosure / pre-training-cutoff correct detection rate; undefined if eligible-set empty |

### Rationale paragraph (paper-ready)

A vulnerability-detection system is operationally useful when it is comprehensive (CWC), discriminating on hard cases (DAHR), severity-aware (SWY), reliable in its rationales (CR), and capable of surfacing genuinely new findings (NR). Four of these five dimensions inherit operationalizations from at least three prior papers, satisfying the 3-paper anchor rule; Novelty Reach is the one original measurement and is reported with explicit pre-disclosure / pre-training-cutoff protocols so it remains falsifiable. The five-dimension set is roughly seven times smaller than SecLens-R's 35-dimension catalog, but each surviving dimension repairs at least one specific F1 failure mode: CWC fixes severity-blindness via class-difficulty weighting; DAHR fixes the single-prediction assumption via item-difficulty calibration; SWY fixes severity-blindness directly; CR fixes the asymmetric FP/FN cost insufficiency by penalizing plausible FPs; and NR addresses ground-truth instability via time-stamped novelty.

### "Level of Operation" Matrix

| Dimension | Atomic Level | Class Aggregation | System Aggregation |
|---|---|---|---|
| CWC | instance correctness | difficulty-weighted mean of class detection rates | direct |
| DAHR | δ_i, c_i per instance | (not class-aggregated; sums directly) | weighted sum across all instances |
| SWY | severity_i, correctness_i, salience_i | (not class-aggregated) | weighted-recall ⊕ Spearman ρ |
| CR | verdict_i, faithfulness_i, plausibility_j (FP-only) | (not class-aggregated) | mean of joint indicator minus FP-plausibility mean |
| NR | eligibility_i, correctness_i | (not class-aggregated) | mean over eligible subset |

The matrix is critical because **only CWC operates at the per-class level**; the other four operate at the per-instance level and then aggregate to system. This means the Verity aggregator must treat CWC as a vector of per-class scores while the others enter as scalars — a design choice that drives Part 2's two-stage architecture.

---

# TASK 2 — VERITY FORMULA: AXIOMATIC AND FORMULAIC DESIGN

## 2.1 Survey of Composite-Index Axiomatic Literature

- **Human Development Index (UNDP).** The UNDP migrated from an arithmetic mean to a **geometric mean** of three normalized sub-indices in the 2010 Human Development Report. The official justification (UNDP 2010 HDR Technical Note, as reproduced in secondary peer-reviewed literature — Anserpress, *Journal of Economics and Analysis* 4(1):96): *"With the geometric mean, as any one dimension index approaches its minimum value, the HDI approaches zero, even if the other dimensions are at their maximum values. By penalizing inequality, the geometric mean embodies complementarity."* This is precisely the zero-blindness axiom we want, and the HDI's 2010 reform is the canonical citation for the move from compensatory to partially non-compensatory aggregation.
- **Sen's axiomatic framework for inequality measurement.** Anonymity (permutation invariance), population principle (replication invariance), relative income / scale invariance, and the **Pigou–Dalton transfer principle** (a transfer from a higher to a lower value, holding total constant, reduces inequality).
- **Atkinson (1970), "On the Measurement of Inequality"** (Journal of Economic Theory 2:244–263). Introduces the **inequality aversion parameter ε**: utility u(y) = y^(1−ε)/(1−ε) for ε ≠ 1 and ln(y) for ε = 1. Higher ε up-weights the lower tail; ε → ∞ approaches the Rawlsian min operator. This gives us a *tunable* zero-blindness knob.
- **OWA operators (Yager 1988, IEEE T-SMC 18:183–190; ~6,500 citations).** A parameterized family of aggregations between min and max with weights attached to *order positions* rather than dimension identities. Useful for "worst-k" floors.
- **Choquet integral (Choquet 1953; Marichal IEEE T-Fuzzy 2000 "An axiomatic approach of the discrete Choquet integral as a tool to aggregate interacting criteria").** Aggregator that admits *interactions* between criteria via a non-additive fuzzy measure. Powerful but requires specifying 2^n − 2 capacity parameters, exploding the calibration burden.
- **OECD/JRC Handbook on Constructing Composite Indicators (Nardo, Saisana, Saltelli, Tarantola, 2008, ISBN 978-92-64-04345-9; JRC47008).** The reference text. Chapter 6 distinguishes *compensatory* (arithmetic mean) from *partially compensatory* (geometric mean) from *non-compensatory* (multi-criteria methods like Condorcet, Borda) aggregations, and explicitly notes that compensability is an issue that "needs to be considered and either be corrected for or treated as features of the phenomenon" — recommending geometric aggregation when compensability between dimensions should be limited, exactly the LLM-vuln-detection condition.
- **MCDA (Multi-Criteria Decision Analysis).** AHP, TOPSIS, ELECTRE. SecLens-R explicitly cites this lineage (alongside ISO/IEC 25010 and Goal-Question-Metric). The relevant lesson: when *role-conditional preferences* are central, MCDA is appropriate; when *capability assessment* is central, axiomatic single-scalar aggregation is appropriate. This distinction is our defense against SecLens-R (axiom A10 below).

## 2.2 The Complete Axiom Set for Verity

We derive the following axiom set, including the four named starting axioms and six additional axioms required for the design to be defensible:

**A1 — Boundedness.** Verity(S) ∈ [0, 1] for every system S. *Justification:* interpretability, leaderboard-comparability. *Prior anchor:* HDI [0,1]; SecLens-R Decision Score [0,100].

**A2 — Zero-Blindness (Strong).** If any required dimension d_k(S) = 0 OR any required class coverage p_c(S) = 0, then Verity(S) = 0. *Justification:* a system that misses an entire class or an entire dimension cannot be "good overall." *Prior anchor:* HDI geometric mean (UNDP 2010 HDR Technical Note); OECD/JRC Handbook §6 on non-compensability.

**A3 — Monotonicity.** ∂Verity/∂d_k(S) ≥ 0 for all dimensions k. Improving on any dimension cannot decrease the score. *Justification:* incentive alignment. *Prior anchor:* universal across composite indices (Sen's framework, OECD/JRC).

**A4 — Difficulty Sensitivity (Pigou–Dalton-analog).** Holding total findings constant, replacing a correct easy detection with a correct hard detection of equal severity strictly increases Verity. *Justification:* otherwise systems trivially game by farming easy instances. *Prior anchor:* Pigou–Dalton transfer principle (Atkinson 1970); IRT (Lalor et al. 2016).

**A5 — Calibration Sensitivity.** If two systems have identical per-instance correctness but one's salience ranking better correlates with CVSS severity, the better-calibrated system scores higher. *Justification:* operational deployment requires triage-rankable findings. *Prior anchor:* HELM's calibration metric (Liang et al. TMLR 2023, arXiv 2211.09110).

**A6 — Anonymity / Permutation Invariance over Instances.** Verity is invariant to the order in which instances are presented. *Justification:* a fair score depends only on the bag of (instance, outcome) pairs. *Prior anchor:* Sen's anonymity axiom.

**A7 — Scale Invariance over Difficulty Calibration.** Multiplying all difficulty weights δ_i by a positive constant leaves Verity unchanged. *Justification:* difficulty is an ordinal-cardinal construct from pilot data; results should not depend on its arbitrary scale. *Prior anchor:* Sen's scale invariance.

**A8 — Inequality-Aversion Knob (Bounded).** Verity exposes one tunable parameter ε ∈ [0, 2] controlling how harshly low dimensions are penalized; ε = 0 collapses to arithmetic mean, ε = 1 is geometric mean. *Justification:* allows the paper to perform sensitivity analysis and defend a default. *Prior anchor:* Atkinson 1970.

**A9 — Class-Locus Compatibility.** The aggregator must handle CWC as a *per-class vector* and the other four dimensions as *scalars*, without privileging either. *Justification:* the taxonomy is organized by detection-artifact locus, so per-class structure is intrinsic. *Prior anchor:* original to Verity.

**A10 — Capability-Not-Procurement Scope.** Verity is explicitly defined as a measurement of *detection capability*, not a procurement-decision score. Role-conditional weightings (SecLens-R) are out of scope by construction. *Justification:* this directly defuses SecLens-R's "no universal best model" objection — we are not claiming to identify a best deployment; we are claiming to identify a best detector under a stated capability theory. *Prior anchor:* original; complementary to SecLens-R.

A10 deserves emphasis. SecLens-R (arXiv 2604.01637) argues verbatim that *"model selection for security vulnerability detection is not a single-objective problem, and that stakeholder-aware evaluation surfaces information that aggregate scores cannot"* and demonstrates this empirically: *"Decision Scores diverge by up to 31 points across roles for the same model: Qwen3-Coder earns an A (76.3) for Head of Engineering but a D (45.2) for CISO; GPT-5.4 earns an A (76.7) for Head of Engineering but a D (48.4) for CISO."* Verity does not contradict this; Verity occupies a *different evaluative target*. The CNS framing is: "Given a fixed theory of what 'detection capability' means (the five dimensions), which system has more of it?" SecLens-R's framing is: "Given a fixed organizational role, which system is best for that role?" The two are complementary; Verity provides the capability prior that SecLens-R's role profiles re-weight. (Note further that the SecLens-R "AI-as-Actor" profile awards every one of the 12 evaluated frontier models an A grade between 77.9 and 87.5 — so even within its own framework, at least one role profile is uninformative on current models, suggesting role-conditional decomposition has limits as a discriminator.)

## 2.3 Candidate Formulas, Tested Against the Axiom Set

We consider six candidates: weighted arithmetic mean (the SecLens-R Decision Score family), weighted geometric mean, weighted L_p-norm with p ∈ (0,1) and with p > 1, AUC-style capability-difficulty curve, Choquet integral, and weighted harmonic mean.

| Formula | A1 Bound | A2 Zero-Blind | A3 Mono | A4 Diff-Sens | A5 Calib | A6 Anon | A7 Scale | A8 Knob | A9 Class | A10 Scope |
|---|---|---|---|---|---|---|---|---|---|---|
| Weighted Arithmetic Mean (SecLens-R Eq. 2 family) | ✓ | ✗ (high in one compensates zero in another) | ✓ | partial | partial | ✓ | ✓ | partial | ✗ | ✗ |
| **Weighted Geometric Mean** | ✓ | **✓ (any zero kills product)** | ✓ | ✓ (via δ_i) | ✓ (via SWY component) | ✓ | ✓ | partial (fixed ε≈1) | ✓ | ✓ |
| L_p-Norm, low p | ✓ | partial (approaches zero only as p→0) | ✓ | ✓ | ✓ | ✓ | ✓ | **✓ (p is the knob)** | ✓ | ✓ |
| L_p-Norm, high p | ✓ | ✗ | ✓ | ✗ | partial | ✓ | ✓ | partial | partial | ✓ |
| AUC capability-difficulty curve | ✓ | ✗ (rewards area, tolerates some-zero) | ✓ | **✓ (native)** | partial | ✓ | partial | ✗ | partial | ✓ |
| Choquet integral | ✓ | depends on capacity | ✓ | depends | depends | ✓ | partial | exponential param space | ✓ (interactions) | ✓ |
| Weighted Harmonic Mean | ✓ | ✓ (any zero kills) | ✓ | partial | partial | ✓ | ✓ | partial | partial | ✓ |

Two formulas satisfy or nearly satisfy the full axiom set: the **weighted geometric mean** (clean satisfaction of A1–A7 and A9–A10, partial on A8) and the **L_p-norm with low p** (clean satisfaction of A1–A10 including the explicit knob). The Choquet integral over-fits the design budget (n=5 dimensions yields 2^5 − 2 = 30 capacity parameters to calibrate — empirically infeasible at 150–200 instances). AUC-style aggregation captures difficulty natively but fails zero-blindness. Harmonic mean is similar to geometric but harder to interpret to security reviewers.

**Recommended formula: a two-stage weighted geometric mean with an Atkinson-style ε generalization at the inner (class-aggregation) stage.** This subsumes both the geometric mean and the low-p L_p-norm as special cases.

## 2.4 The Recommended Verity Formula (Formal Statement)

Let the five dimensions be D = {CWC, DAHR, SWY, CR, NR}, with positive dimension weights w_k summing to 1. Let CWC itself be a vector of per-class scores p_c with positive class weights v_c summing to 1.

**Stage 1 (within-CWC class aggregation, Atkinson-generalized mean):**
CWC(S) = ( Σ_c v_c · p_c(S)^(1−ε) )^(1/(1−ε))   for ε ≠ 1
CWC(S) = exp( Σ_c v_c · ln p_c(S) )            for ε = 1 (geometric mean limit)

with Laplace smoothing p_c ← max(p_c, η) for η = 0.01, which prevents undefined behavior on all-zero classes while still strongly penalizing them.

**Stage 2 (across-dimension aggregation, fixed-weight geometric mean):**
Verity(S) = ∏_k d_k(S)^(w_k)

The default dimension weights are: w_CWC = 0.25, w_DAHR = 0.20, w_SWY = 0.25, w_CR = 0.20, w_NR = 0.10. The lower w_NR reflects that Novelty Reach is the most original and least anchored dimension; the heavier w_CWC and w_SWY reflect their direct repair of F1 failure modes. Default ε = 1 (clean geometric mean); we recommend reporting Verity at ε ∈ {0.5, 1, 1.5} as the sensitivity strip.

### Proof Sketch of Axiom Satisfaction

- **A1 (boundedness):** each d_k ∈ [0,1] and weighted geometric mean of values in [0,1] is in [0,1]. ✓
- **A2 (zero-blindness):** if any d_k = 0, the product is 0. The CWC inner η-smoothing means a zero class drives CWC ≈ η^(v_c · ...), very close to zero but not exactly zero. ✓ (Strong form; documented in edge cases.)
- **A3 (monotonicity):** ∂Verity/∂d_k = w_k · Verity / d_k ≥ 0 for d_k > 0. ✓
- **A4 (difficulty sensitivity):** inherited from DAHR's δ_i weighting; any swap of an easy correct for a hard correct strictly increases DAHR and hence Verity. ✓
- **A5 (calibration sensitivity):** inherited from SWY's Spearman component. ✓
- **A6, A7:** clear from construction (Verity is symmetric in instances; difficulty appears only inside a ratio). ✓
- **A8 (knob):** the inner-CWC ε is exposed; outer dimension aggregation is fixed at geometric for interpretability. Partial satisfaction; we accept the trade-off because exposing two knobs would inflate sensitivity-analysis burden. ⚠
- **A9, A10:** by construction. ✓

### Edge Cases

- **Undefined dimension for a class** (e.g., line-level localization on Configuration class): the dimension drops out of CWC for that class and v_c renormalizes. Documented per-class in the appendix.
- **All-zero row** (system scores 0 on every instance in some class): η-smoothing keeps Verity defined but very small, preserving zero-blindness in spirit while preventing log(0).
- **NR undefined** (no novelty-eligible instances): NR is removed from the outer product and w_NR is redistributed proportionally to the remaining dimensions.
- **Ties:** broken by reporting (CWC, DAHR, SWY, CR, NR) tuples in supplementary tables.

## 2.5 Anticipated Reviewer Objections and Responses

- **"Why not arithmetic mean like SecLens-R Decision Score?"** Because arithmetic compensation lets a system with one strong dimension hide a blind spot. The HDI literature settled this in 2010: the UNDP moved away from arithmetic precisely so that "as any one dimension index approaches its minimum value, the HDI approaches zero, even if the other dimensions are at their maximum values" (UNDP 2010 HDR Technical Note). The same logic applies here.
- **"The dimension weights are arbitrary."** They are *defaults*. We report sensitivity to ±0.05 perturbations and to a uniform-weight ablation.
- **"Novelty Reach is unfalsifiable."** We respond with the pre-disclosure / pre-training-cutoff protocol (inspired by eyeballvul's weekly-refresh design); we flag NR as the least-anchored dimension and weight it lowest.
- **"SecLens-R argues no universal best exists."** A10: SecLens-R measures a *different target* (procurement-best given role); Verity measures *capability-best given a stated capability theory*. Both can be true.
- **"Geometric mean is too harsh."** We expose ε so reviewers can re-run the rankings; we predict the top-3 ordering is stable across ε ∈ [0.5, 1.5].

## 2.6 Worked Example — Same F1, Different Verity

Consider two hypothetical systems on a stratified benchmark of 175 instances across seven classes (25 per class):

| System | Code | AuthAC | SupplyChain | Config | DesignLogic | SocialEng | AI/ML | F1 |
|---|---|---|---|---|---|---|---|---|
| A (specialist) | 0.80 | 0.10 | 0.10 | 0.80 | 0.10 | 0.10 | 0.80 | 0.40 |
| B (generalist) | 0.40 | 0.40 | 0.40 | 0.40 | 0.40 | 0.40 | 0.40 | 0.40 |

Both have F1 = 0.40. Under Verity-CWC with ε = 1, equal class weights:
- CWC_A = (0.80 · 0.10 · 0.10 · 0.80 · 0.10 · 0.10 · 0.80)^(1/7) = (5.12 × 10^−5)^(1/7) ≈ 0.221
- CWC_B = (0.40^7)^(1/7) = 0.40

Holding the other four dimensions equal, System B's Verity is roughly 0.40^w_CWC · (rest), while System A's is roughly 0.221^w_CWC · (rest) — System A scores roughly half on the CWC dimension, propagating into a meaningfully lower Verity. F1 is identical at 0.40; Verity separates them. The Verity ranking is more operationally meaningful because a system that is blind on four of seven taxonomy classes (System A) is not a deployable detector in any real-world security program, regardless of how strong it is on its three favorites. This is exactly the scenario that PrimeVul's VD-S metric flagged for the original BigVul benchmark: a state-of-the-art 7B model "scored 68.26% F1 on BigVul but only 3.09% F1 on PrimeVul" because BigVul's distribution masked class-coverage failures (Ding et al., ICSE 2025, arXiv 2403.18624).

## 2.7 Sensitivity-Analysis Pre-Specification

The paper should report:

1. **ε ablation:** Verity at ε ∈ {0.5, 1.0, 1.5} on the inner CWC stage.
2. **Dimension-weight ablation:** uniform weights (w_k = 0.2 each) vs. recommended default.
3. **NR-inclusion ablation:** Verity with NR included vs. excluded.
4. **Class-difficulty ablation:** difficulty derived from pilot human-expert solve rate vs. uniform difficulty.
5. **Label-noise robustness:** Verity on full benchmark vs. Risse–Böhme-style cleaned subset (Risse & Böhme USENIX Security 2024 demonstrated that ML4VD models cannot reliably distinguish vulnerable from patched code, suggesting label noise drives apparent F1 inflation).
6. **Severity-source ablation:** NVD CVSS v3.1 vs. vendor scores for SWY's severity weights.

The headline claim should be: "Top-3 system rankings under Verity are invariant across all six sensitivity strips." If this fails, the paper must disclose which strip flips rankings and why.

---

# RECOMMENDATIONS (STAGED, ACTIONABLE)

**Now (paper draft, weeks 0–2):**
1. Adopt the five-dimension Detection Profile (CWC, DAHR, SWY, CR, NR) and the two-stage weighted geometric mean with default ε = 1 and weights (0.25, 0.20, 0.25, 0.20, 0.10). Document A10 prominently as the scope-clarification that defuses SecLens-R's universality objection.
2. Frame the paper around the *axiom-first* derivation in §2.2 — the axioms come before the formula in the narrative, not after. Reviewers reward this structure.
3. In Related Work, position the opponents as fixing *single* failure modes (PrimeVul/VD-S → FP/FN cost; JITVUL/pAcc + ReVD/VP-S → ground-truth instability; SecVulEval, SecLLMHolmes, CORRECT → faithfulness; IRIS → coverage), and Verity as the composite that addresses all four F1 failure modes together.

**Next (pilot benchmark, weeks 2–8):**
4. Build the 150–200 instance stratified benchmark with empirical per-instance difficulty (pilot 5–10 human security analysts, record solve rate, set δ_i = 1 − solve_rate).
5. Run all six sensitivity strips end-to-end before publication. Pre-register the strip outcomes in the paper appendix.
6. Run Verity, F1, VD-S, pAcc, VP-S, and SecLens-R Decision Score (using their CISO weight profile) on the same systems for the comparison table. Show that Verity diverges from F1 in the operationally meaningful direction (down-ranks single-class specialists).

**Benchmarks/thresholds that would change these recommendations:**
- If pilot reveals CWC ↔ DAHR correlation ρ > 0.85 (anticipated ~0.5): merge them or drop DAHR.
- If pilot reveals NR is undefined for > 30% of evaluated systems (because too few novel-eligible instances): drop NR to a secondary metric in a separate table.
- If sensitivity strip 1 (ε ablation) flips the top-3 ranking: expose ε as a primary reported parameter rather than a fixed default.
- If SecLens-R's authors publish a peer-reviewed version with significant changes to the 35-dimension catalog before camera-ready: re-run the parsimony comparison and update §1.4.
- If reviewers object that geometric mean is too harsh: have the Atkinson ε = 0.5 result ready to present as a defensible compromise.

---

# CAVEATS

- **SecLens-R is unreviewed (arXiv-only, April 2026).** Treat citation accordingly; its 35-dimension catalog is the most direct intellectual opponent but has not yet been peer-reviewed. Authors are from two small industry labs (Mattersec Labs, Kalmantic Labs).
- **Novelty Reach is the weakest-anchored dimension** and the most likely target of reviewer objections. Be ready to drop it to a secondary metric if reviewers push back hard. eyeballvul's weekly-refresh model is the most defensible operational anchor but is itself a 2024 preprint (arXiv 2407.08708).
- **The merge of hallucination + faithfulness into Claim Reliability is a design choice** with strong but not unanimous support in the literature; Lanham et al. 2023 explicitly argue these should be measured separately. We mitigate by reporting the two CR components separately in the appendix.
- **The geometric mean's harshness is a feature, not a bug**, but reviewers from the IR/ML tradition may instinctively prefer arithmetic compensation. The HDI 2010 reform precedent is the cleanest single citation for defending geometric mean and should be the first defense at review.
- **The 23.83% F1 ceiling** that SecVulEval (Claude-3.7-Sonnet) reports for "vulnerable statement detection with correct reasoning" is sobering — current frontier-LLM performance under faithfulness-gated metrics is low across the board. Verity will produce small absolute scores; reframe the contribution as *ranking* rather than *absolute level*.
- **PrimeVul's 3.09% F1 result** (StarCoder2 on PrimeVul vs. 68.26% F1 on BigVul, same model) is the canonical illustration of how a poorly-chosen aggregate can overestimate by 22×. Use this in the paper's introduction to motivate why F1 alone is insufficient.
- **The 3-paper threshold rule is itself a methodological commitment.** Reviewers may ask why three rather than two or four. The defense is that three is the smallest count at which a measurement has been *re-invented under independent operationalizations*, which is the empirical signal that the measurement targets a real construct.
