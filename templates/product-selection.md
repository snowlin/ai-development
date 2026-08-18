# Product Selection Gate

> 仓库级可选 Gate 模板。初始化项目时不会复制本文件；仅在产品方向选择或未经验证需求触发时按需读取。

## Purpose

`product-selection` is a product opportunity selection, validation, and productization gate.

Its purpose is **not** to help the user build faster.

Its purpose is to help the user decide:

1. What is worth investigating?
2. What is worth testing?
3. What evidence is still missing?
4. What should be rejected or parked?
5. When does an idea deserve productization?
6. What is the smallest bottleneck worth building?

The skill exists because cheap AI labor changes the founder's bottleneck:

> Building became cheap.  
> Selection, judgment, attention, and delivery did not.

The skill therefore optimizes for:

> **better selection before more construction**

rather than:

> **more construction before better evidence**

---

# Core Principles

## Principle 1 — Default No

The default decision is:

```yaml
should_build: false
```

An idea does not earn development resources because:

- it sounds interesting;
- AI can build it quickly;
- the founder likes it;
- competitors exist;
- a market appears large;
- people say it is useful.

Evidence must reverse the default.

```text
DEFAULT = NO

Evidence may change:
NO → YES

Excitement may not.
```

---

## Principle 2 — Validate the Transaction Before Optimizing the Product

> **Never optimize the product before validating the transaction.**

Before discussing:

- features;
- UI;
- architecture;
- agents;
- dashboards;
- automation;
- databases;
- integrations;

first determine whether a meaningful transaction exists.

A transaction requires:

- a buyer;
- a trigger;
- a problem;
- a desired outcome;
- a reason to act now;
- a deposit, signed LOI, paid pilot, customer data access, or another explicitly recorded commitment.

---

## Principle 3 — Never Turn Assumptions Into Requirements

> **Never convert an unverified assumption into a product requirement.**

Example:

User says:

> Users probably need a dashboard.

Record:

```yaml
hypothesis:
  statement: "Users need a dashboard."
  evidence: none
```

Do not automatically create:

```text
Requirement: Build dashboard
```

Instead ask:

> Can we first deliver the result by email, document, chat, or manually and observe whether users actually demand a dashboard?

---

## Principle 4 — Cheap to Build Does Not Mean Cheap to Pursue

Development cost is no longer the full cost of an idea.

The real cost may include:

- founder attention;
- distribution effort;
- positioning;
- customer support;
- operational complexity;
- context switching;
- sales effort;
- emotional commitment;
- opportunity cost.

Therefore always distinguish:

```text
BUILD COST
```

from:

```text
PURSUIT COST
```

An idea that takes two days to build may consume six months of attention.

---

## Principle 5 — AI Generates; Humans Discriminate

AI may assist with:

- generating options;
- summarizing evidence;
- designing experiments;
- researching markets;
- identifying risks;
- producing implementation alternatives.

AI should not silently become the final decision maker.

The human owns:

- objectives;
- tradeoffs;
- accountability;
- final judgment;
- acceptable risk.

Core rule:

> **Offload generation. Keep discrimination.**

The skill should help improve the user's decision process, not replace it.

---

# When to Invoke This Skill

Use this skill when the user:

- proposes a product idea;
- says "I want to build...";
- asks what product to build;
- asks whether a product is worth building;
- asks for an MVP for an unvalidated idea;
- proposes an AI SaaS;
- proposes an agent product;
- wants to choose between two or more competing product ideas;
- wants to create a startup;
- asks whether a feature has commercial value;
- wants to turn a workflow into software;
- presents a PRD whose requirements are mostly assumptions;
- wants to commit meaningful resources to a new product direction.

Example triggers:

```text
"I want to build an AI assistant for lawyers."

"Is this product worth doing?"

"Help me plan a SaaS for restaurants."

"I have three startup ideas."

"What MVP should I build for this problem?"
```

---

# When Not to Invoke

Do not invoke when:

- the user explicitly wants a hobby project;
- commercial validation is irrelevant;
- the user is debugging existing code;
- the product and demand are already validated;
- the user explicitly wants implementation despite commercial uncertainty;
- the task is routine optimization inside an already-proven product.

If the user explicitly says:

> I know this is unvalidated, but I want to build it anyway.

Proceed, but label:

```text
Design decision — not validated customer requirement.
```

---

# The Product Selection Lifecycle

Use this sequence:

```text
IDEA
  ↓
OBJECTIVE
  ↓
TRANSACTION
  ↓
FACT / HYPOTHESIS / UNKNOWN
  ↓
BIGGEST UNKNOWN
  ↓
CHEAPEST DECISIVE TEST
  ↓
PULL
  ↓
ECONOMICS
  ↓
EXCEPTION ECONOMICS
  ↓
REPEATABILITY
  ↓
COMPOUNDING
  ↓
CONTROL POINT
  ↓
RIGHT TO WIN
  ↓
ATTENTION COST
  ↓
PRODUCTIZE / PARK / STOP
  ↓
BUILD THE BOTTLENECK
```

Avoid:

```text
IDEA
  ↓
FEATURE LIST
  ↓
PRD
  ↓
ARCHITECTURE
  ↓
BUILD
  ↓
LAUNCH
  ↓
HOPE
```

---

# Stage 1 — Define the Game

Before evaluating whether an idea is good, determine what "good" means for this user.

There are three common games.

---

## Game A — Cash Flow

Main question:

> Can this repeatedly produce profitable transactions?

Optimize for:

- time to first revenue;
- owner earnings;
- low capital exposure;
- manageable operations;
- an initial sales cycle shorter than 30 days;
- predictable demand.

Do **not** require venture-scale defensibility.

A business may succeed through:

- convenience;
- local relationships;
- service quality;
- operational excellence;
- fragmentation;
- customer inertia.

---

## Game B — Durable Company

Main question:

> Does the business become structurally stronger as it serves more customers?

Look for:

- retention;
- integrations;
- workflow embedding;
- reputation;
- referrals;
- cost improvements;
- switching costs;
- proprietary operational knowledge.

---

## Game C — Venture Scale

Main question:

> Can this become an unusually large category-defining company?

Additional questions:

- Can the market become very large?
- Can distribution scale?
- Can power accumulate?
- Can the company become a control point?
- Is there potential for nonlinear upside?

---

# Objective Function

Capture when possible:

```yaml
objective_function:
  game:
  target_annual_revenue:
  target_owner_earnings:
  target_company_scale:
  time_to_first_revenue:
  time_horizon:
  maximum_capital_at_risk:
  maximum_sales_cycle:
  employee_tolerance:
  operational_complexity_tolerance:
  regulation_tolerance:
  liability_tolerance:
```

Unknown fields should remain unknown.

Do not invent preferences for the user.

---

# Stage 2 — Convert the Idea Into a Transaction

A product category is not a transaction.

Weak:

```text
AI for education
AI marketing
AI assistant for doctors
AI writing app
```

A usable product hypothesis should identify:

```yaml
transaction:
  buyer:
  user:
  trigger:
  current_problem:
  current_solution:
  frequency:
  cost_of_failure:
  desired_outcome:
  measurable_completion_state:
  required_inputs:
  reason_to_act_now:
  payment_basis:
```

---

# Transaction-Shaped Problem Test

A strong problem usually contains:

1. Observable trigger
2. Reachable buyer
3. Named owner
4. Meaningful pain
5. Repeated occurrence
6. Measurable completion
7. Obtainable inputs
8. Detectable errors
9. Consequence for failure
10. Reason to act now

Weak:

> Improve marketing for local businesses.

Stronger:

> When a qualified commercial roofing lead arrives, respond within three minutes, generate a compliant estimate, and book an inspection.

---

# Stage 3 — Fact / Hypothesis / Unknown

Every important claim should be classified.

## Fact

Supported by actual evidence.

Examples:

```text
Three users paid $300.

The workflow currently takes five hours per week.

The customer gave production data access.

The customer currently employs two people to perform this task.
```

---

## Hypothesis

Believed but unproven.

Examples:

```text
Users will pay $99/month.

Users need a dashboard.

AI can automate 90%.

The buyer cares about speed.

Customers will switch from the incumbent.
```

---

## Unknown

Important but not yet investigated.

Examples:

```text
Who owns the budget?

How common are exceptions?

Can required data legally leave the system?

How long is procurement?

How expensive is human review?
```

---

# Never Promote Without Evidence

Forbidden behavior:

```text
User belief
↓
AI agreement
↓
Product requirement
```

Required behavior:

```text
User belief
↓
Hypothesis
↓
Experiment
↓
Evidence
↓
Decision
```

---

# Stage 4 — Evidence Hierarchy

## Very Weak

- likes;
- compliments;
- social engagement;
- AI-generated arguments;
- trend reports;
- "cool idea."

## Weak

- surveys;
- waitlists;
- casual interview interest;
- non-binding LOIs;
- hypothetical willingness to pay.

## Moderate

- repeated interviews revealing the same behavior;
- real workflow examples;
- customer provides sample data;
- customer invests meaningful setup time.

## Strong

- payment;
- deposit;
- paid pilot;
- real system access;
- production data;
- signed operational commitment;
- workflow change;
- purchase order.

## Very Strong

- repeated paid transactions;
- renewals;
- expansion revenue;
- referrals;
- multiple customers acquired through the same channel.

Always identify:

```yaml
evidence_quality:
  strongest_evidence:
  weakest_assumption:
  missing_evidence:
```

---

# Stage 5 — Find the Biggest Unknown

Do not produce ten tests.

Find:

> **The uncertainty whose answer would most change the decision.**

Possible examples:

- Will anyone pay?
- Can we reach the buyer?
- Is the pain frequent enough?
- Can we get the data?
- Is the outcome measurable?
- Are exceptions too expensive?
- Is procurement impossible?
- Is the buyer actually authorized?

Output:

```yaml
biggest_unknown:
  question:
  why_it_matters:
```

---

# Stage 6 — Cheap Search

The goal is not:

> Build the smallest product.

The goal is:

> **Run the cheapest decisive experiment.**

Default preference:

```text
Interview
↓
Direct Sale
↓
Paid Manual Service
↓
Concierge Delivery
↓
Human + AI Delivery
↓
Semi-Automation
↓
Prototype
↓
Software
↓
Full Product
```

Always ask:

> Could we learn this without building software?

---

# Falsifiable Experiment Requirement

Every important experiment should define failure in advance.

Bad:

> Talk to users and see if they like it.

Better:

> Offer the service to five qualified buyers at $300/month. If nobody pays, reject the current willingness-to-pay hypothesis.

Bad:

> Launch a landing page.

Better:

> Send the landing page directly to 30 qualified prospects. Require a booked call or deposit, not merely page views.

Experiment format:

```yaml
experiment:
  hypothesis:
  method:
  target_participants:
  required_commitment:
  sample_size:
  success_criteria:
  kill_criteria:
  expected_learning:
```

---

# Stage 7 — Paid Concierge Before Product

When possible, sell the result before building the software.

Example:

Instead of:

> Build an AI competitor research SaaS for creators.

Test:

> Sell five creators a weekly competitor intelligence report produced manually with AI.

Concierge delivery helps uncover:

- willingness to pay;
- hidden workflow complexity;
- inputs;
- exceptions;
- quality expectations;
- actual labor;
- required integrations;
- pricing logic.

Manual delivery is not failure.

It is often:

> **high-quality market research that customers pay for.**

---

# Stage 8 — Pull

Question:

> Does the market actively pull the solution?

Strong signals:

- customer pays quickly;
- customer gives data;
- customer gives access;
- customer changes workflow;
- customer introduces others;
- urgency exists;
- sales friction is low relative to the category.

Weak signals:

- "interesting";
- "maybe later";
- "send me information";
- no owner;
- no budget;
- excessive education required.

Output:

```yaml
pull:
  status: unproven | weak | promising | validated
  evidence:
```

---

# Stage 9 — Economics

Calculate the real transaction economics.

Include:

- AI inference;
- human review;
- onboarding;
- support;
- rework;
- sales effort;
- implementation;
- integrations;
- liability;
- guarantees;
- working capital;
- acquisition cost.

Do not use:

```text
Revenue - API Cost
```

as gross economics.

Output:

```yaml
economics:
  status: unproven | weak | promising | validated
  revenue_per_transaction:
  direct_ai_cost:
  human_cost:
  exception_cost:
  support_cost:
  other_direct_cost:
  estimated_margin:
```

Use `unknown` where evidence is missing.

---

# Stage 10 — Exception Economics

For AI products, this stage is mandatory.

The key question is not:

> How accurate is the model?

It is:

> **What is the cost and consequence of the cases it fails to handle cleanly?**

Capture:

```yaml
exception_economics:
  automation_rate:
  exception_rate:
  exception_detectability:
  human_review_minutes:
  required_operator_skill:
  rework_rate:
  false_positive_cost:
  false_negative_cost:
  escalation_cost:
  liability_exposure:
  support_cost:
  exception_rate_trend_with_scale:
```

---

# Important Exception Rule

95% automation may be excellent if:

- failures are visible;
- exceptions are easy to identify;
- correction is cheap;
- errors are reversible.

95% automation may be commercially terrible if:

- failures are silent;
- mistakes are catastrophic;
- experts must review them;
- liability is high.

Never infer business viability from benchmark accuracy alone.

---

# Staffing Warning

If:

```text
transaction volume ↑
and
human exception labor ↑ proportionally
```

then the business may behave more like:

> an AI-assisted services company

than:

> scalable software.

This may still be a good business.

Label it accurately.

---

# Stage 11 — Repeatability

Question:

> Can the same transaction be won repeatedly?

Check whether these remain similar:

- trigger;
- buyer;
- pain;
- offer;
- pricing logic;
- acquisition channel;
- delivery process.

One friendly buyer is not repeatability.

Output:

```yaml
repeatability:
  status: unproven | weak | promising | validated
  repeated_customer_count:
  evidence:
```

Useful question:

> Could we sell this to the next ten customers using roughly the same process?

---

# Stage 12 — Compounding

Do not ask:

> Do we already have a moat?

Ask:

> **Does repeated delivery make the business structurally stronger?**

Potential compounding assets:

- proprietary data;
- exception data;
- integrations;
- workflow knowledge;
- trust;
- brand;
- referrals;
- lower cost;
- better predictions;
- regulatory knowledge;
- distribution;
- workflow control.

Output:

```yaml
compounding:
  status: none | speculative | plausible | demonstrated
  mechanism:
  accumulated_asset:
  evidence:
```

---

# Causal Mechanism Requirement

Weak:

> More users create more data, therefore moat.

Strong:

> Every completed transaction produces labeled exception data, and that data has reduced manual review time from 20 minutes to 8 minutes.

Require:

```text
More activity
↓
Specific accumulated asset
↓
Measurable improvement
↓
Stronger position
```

---

# Stage 13 — Control Point

Replace:

> tool vs outcome

with:

> **replaceable participant vs control point**

Possible control points:

- system of record;
- authorization layer;
- approval workflow;
- payment flow;
- ledger;
- identity;
- write access;
- compliance checkpoint;
- customer communication channel;
- required operational system.

Output:

```yaml
control_point:
  current_position:
  replaceability:
  workflow_dependency:
  switching_cost:
  potential_control_point:
  path_to_control:
```

Core question:

> If a competitor copies the interface tomorrow, what position do we still own?

---

# Stage 14 — Right to Win

Do not require:

> Only You.

Almost nothing is literally only buildable by one founder.

Instead evaluate:

> **Why are we more likely to win than a random competent competitor?**

Advantages may be:

## Existing

- domain expertise;
- distribution;
- existing customers;
- trust;
- data;
- brand;
- licenses;
- operational infrastructure.

## Acquirable

- specialized learning;
- partnerships;
- hiring;
- acquisition;
- working inside the industry;
- manual delivery;
- licensing;
- new channel development.

Output:

```yaml
right_to_win:
  current_advantage:
  acquirable_advantage:
  advantage_strength:
  acquisition_cost:
  time_to_acquire:
```

Do not reject an idea solely because the founder lacks an advantage today.

Ask:

> Can an advantage be manufactured at acceptable cost?

---

# Stage 15 — Attention Economics

Attention is a scarce resource.

Evaluate not only:

```text
How cheap is this to build?
```

but:

```text
How expensive is this to pursue?
```

Capture:

```yaml
attention_cost:
  founder_hours_per_week:
  expected_time_until_signal:
  sales_attention:
  operational_attention:
  support_attention:
  context_switching_cost:
  expected_duration_before_clear_decision:
  opportunity_cost:
```

Core question:

> If this idea is wrong, how much scarce attention will we spend before learning that?

Prefer experiments with high:

> **information gained per unit of attention**

---

# Stage 16 — Selection Portfolio

Do not force every rejected idea into permanent deletion.

Use six states:

```text
EXPLORE
VALIDATE
MANUAL_DELIVERY
PRODUCTIZE
PARK
STOP
```

---

# EXPLORE

Use when:

- transaction unclear;
- buyer unclear;
- problem vague;
- important context missing.

Next:

> Clarify the transaction.

---

# VALIDATE

Use when:

- transaction is clear;
- evidence weak;
- willingness to pay unproven.

Next:

> Run the cheapest decisive test.

---

# MANUAL_DELIVERY

Use when:

- someone commits;
- workflow remains poorly understood;
- exceptions remain unknown.

Next:

> Deliver manually with AI assistance.

---

# PRODUCTIZE

Use when:

- pull exists;
- economics are promising;
- exceptions are manageable;
- repeatability is visible;
- repeated delivery exposes a bottleneck.

Next:

> Build the bottleneck.

---

# PARK

Use when:

> The idea is currently unattractive, but a specific condition may later change the decision.

Example:

```yaml
parking_lot:
  failed_condition: "No access to required hospital data."
  reopen_when: "A hospital partner provides compliant API access."
```

Parking is:

> decisive refusal with memory.

---

# STOP

Use when:

- economics structurally fail;
- liability is unacceptable;
- buyer urgency is absent;
- required access is impossible;
- exception costs destroy the business;
- opportunity fundamentally conflicts with the user's objective.

Stopping is not failure.

It is successful search.

---

# Stage 17 — One-Way No

The system should make rejection easy and approval expensive.

Use:

```text
Idea
↓
NO
↓
Evidence
↓
Maybe
↓
More Evidence
↓
YES
```

Avoid:

```text
Idea
↓
Excitement
↓
YES
↓
Build
↓
Post-hoc justification
```

A cheap build should never itself count as a reason to build.

If the user says:

> It only takes a weekend.

The skill should ask:

> What evidence does spending the weekend produce that could not be obtained more cheaply?

---

# Stage 18 — Build Only the Bottleneck

Once productization is justified, do not automatically build a full product.

Find the repeated bottleneck.

Examples:

- normalization;
- exception classification;
- document ingestion;
- approval;
- integration;
- customer onboarding;
- permission management;
- reporting;
- reconciliation.

Output:

```yaml
build_recommendation:
  should_build:
  bottleneck:
  evidence_for_bottleneck:
  smallest_useful_build:
  what_not_to_build_yet:
```

The product should emerge from:

> repeated delivery pain

not:

> imagination.

---

# Productization Gate

Recommend `PRODUCTIZE` when most of these are true:

- real buyer exists;
- real commitment exists;
- workflow is understood;
- desired outcome is measurable;
- repeated delivery has occurred;
- major exceptions are visible;
- economics remain attractive after exceptions;
- repeatability appears plausible;
- software removes a demonstrated bottleneck.

Do not require perfect certainty.

Require meaningful evidence.

---

# Stage 19 — Selection Calibration

Selection skill improves only when predictions are compared with outcomes.

For meaningful decisions record:

```yaml
selection_prediction:
  date:
  idea:
  decision:
  confidence:
  predicted_result:
  expected_time_to_signal:
  key_reason:
```

After the experiment:

```yaml
actual_result:
  outcome:
  measured_result:
  prediction_error:
  key_learning:
```

Then evaluate recurring biases.

Examples:

```text
We repeatedly overestimate willingness to pay.

We underestimate sales cycle.

We overvalue large markets.

We underestimate implementation cost.

We reject unfamiliar industries too quickly.

We underestimate exception cost.
```

The goal is to transform:

> taste as intuition

into:

> judgment with a measurable feedback loop.

---

# Stage 20 — Kill Criteria

Every experiment should define stop conditions before results arrive.

Examples:

```yaml
kill_criteria:
  - criterion: "0 paid pilots after 10 qualified sales conversations"
    implication: "Current offer/value hypothesis rejected"

  - criterion: "Human review remains above 30 minutes per transaction after 100 transactions"
    implication: "Automation economics currently fail"

  - criterion: "Sales cycle exceeds 120 days"
    implication: "Violates founder objective function"
```

Kill criteria protect against:

- sunk-cost bias;
- founder attachment;
- rationalization;
- endless pivots inside the same failed assumption.

---

# Comparing Multiple Ideas

When multiple ideas exist, evaluate each on:

1. Objective fit
2. Transaction clarity
3. Buyer accessibility
4. Pain strength
5. Evidence strength
6. Time to paid test
7. Last-mile difficulty
8. Exception economics
9. Repeatability
10. Compounding potential
11. Control-point potential
12. Right-to-win
13. Attention cost

Do not necessarily select:

> the idea with the highest theoretical upside.

When founder attention is the primary constraint, prefer:

> the idea that can generate the most decisive information with the least scarce attention.

Core metric:

> **Information Value / Attention Cost**

---

# Optional Scoring

Scores are secondary.

Never substitute a score for evidence.

Possible scale:

| Dimension | 0 | 1 | 2 |
|---|---|---|---|
| Objective fit | poor | partial | strong |
| Transaction clarity | vague | partial | clear |
| Evidence | none | weak | strong |
| Economics | poor | uncertain | attractive |
| Exception economics | dangerous | unknown | manageable |
| Repeatability | none | signs | demonstrated |
| Compounding | none | plausible | demonstrated |
| Control point | replaceable | possible | strong |
| Right to win | none | acquirable | strong |
| Attention efficiency | poor | medium | strong |

Important:

> Evidence points are earned only from evidence.

Never score:

> "Users will probably pay."

as validated evidence.

---

# Required Response Structure

When the skill activates, use this structure.

## Current Decision

One:

```text
EXPLORE
VALIDATE
MANUAL DELIVERY
PRODUCTIZE
PARK
STOP
```

Give one concise reason.

---

## Objective

```yaml
game:
target:
constraints:
```

---

## Transaction

```yaml
buyer:
user:
trigger:
problem:
current_solution:
desired_outcome:
completion_state:
reason_to_act_now:
payment_basis:
```

Use `unknown` when unknown.

---

## Facts

Only supported claims.

---

## Hypotheses

Important unverified assumptions.

---

## Unknowns

Unknowns that could change the decision outcome.

---

## Evidence Quality

```yaml
strongest_evidence:
weak_evidence:
missing_evidence:
```

---

## Commercial Gates

```yaml
pull:
economics:
exception_economics:
repeatability:
compounding:
```

Each receives:

```text
unproven
weak
promising
validated
```

Assign one status to each gate. Use `not_applicable` only when the gate cannot be evaluated for the current business model.

---

## Strategic Position

```yaml
control_point:
right_to_win:
attention_cost:
```

---

## Biggest Unknown

Choose exactly one.

---

## Next Experiment

Only one primary experiment.

```yaml
hypothesis:
method:
target:
required_commitment:
success_criteria:
kill_criteria:
```

---

## Build Recommendation

Default:

```yaml
should_build: false
```

If justified:

```yaml
should_build: true
bottleneck:
smallest_useful_build:
what_not_to_build_yet:
```

---

## Parking Condition

If `PARK`:

```yaml
failed_condition:
reopen_when:
```

---

# Conversation Behavior

Do not interrogate the user with 30 questions.

Use progressive discovery.

Ask only questions that materially affect the next decision.

Prefer:

> Who would approve payment for this?

over:

> Please complete this entire startup questionnaire.

If enough information exists to propose an experiment, propose it.

Do not delay action merely to complete a template.

---

# Adversarial Mode

The skill should be constructive but intentionally resistant to founder enthusiasm.

Its job is not:

> prove the idea is good.

Its job is:

> discover what reality says.

Actively search for:

- hidden labor;
- fake automation;
- exception cost;
- inaccessible data;
- false buyer assumptions;
- weak urgency;
- unclear transaction;
- one-off custom services disguised as product;
- distribution assumptions;
- regulatory risk;
- liability;
- fake data moats;
- vanity validation;
- excessive attention cost.

Useful questions:

> Who pays?

> Why now?

> What do they do today?

> What happens if they do nothing?

> Could we test this without software?

> What evidence would prove this idea wrong?

> What happens in the 5% AI cannot handle?

> If we had 100 customers, what breaks first?

> What becomes stronger after customer 100?

> If a competitor copied the UI tomorrow, what remains?

> Why are we more likely to win?

> Can that advantage be manufactured?

> How much attention will we lose if this thesis is wrong?

---

# Anti-Patterns

## Feature Inflation

Bad:

> Here are 20 MVP features.

Correct:

> First identify the transaction and the biggest uncertainty.

---

## Fake Validation

Bad:

> Ten people said it was useful, so demand is validated.

Correct:

> This is weak evidence. Seek payment, access, data, or operational commitment.

---

## Premature Moat

Bad:

> You need a moat before starting.

Correct:

> Identify whether repeated delivery creates a plausible compounding mechanism.

---

## Only-You Fallacy

Bad:

> You do not currently have unfair access, so do not enter the market.

Correct:

> Determine whether useful access or expertise can be manufactured economically.

---

## Accuracy Worship

Bad:

> Model accuracy is 97%, therefore viable.

Correct:

> Evaluate the remaining 3% and its consequences.

---

## Cheap-Build Fallacy

Bad:

> It only takes two days, so just build it.

Correct:

> Building cost is not pursuit cost. What evidence does the build create?

---

## Premature SaaS

Bad:

> One customer paid, now build the SaaS.

Correct:

> Repeat delivery and understand exceptions first.

---

## Vanity Evidence

Do not equate:

- followers;
- downloads;
- impressions;
- waitlists;
- likes

with:

- payment;
- retention;
- workflow commitment;
- repeat transactions.

---

# Handoff to Product Planning

Only hand off when:

```yaml
decision: PRODUCTIZE
build_recommendation:
  should_build: true
```

Recommended handoff:

```yaml
productization_handoff:
  objective:
  validated_transaction:
  buyer:
  user:
  trigger:
  desired_outcome:
  current_workflow:
  paid_evidence:
  pull:
  economics:
  exception_economics:
  repeatability:
  compounding_mechanism:
  control_point:
  right_to_win:
  attention_constraints:
  bottleneck_to_build:
  assumptions_still_open:
  constraints:
```

The downstream Product Planning skill may then design:

- workflows;
- UX;
- requirements;
- MVP scope;
- architecture;
- implementation.

Unverified assumptions must remain labeled.

---

# Final Operating Rules

When this skill is active, continually move the conversation:

```text
IDEA
→ TRANSACTION

OPINION
→ EVIDENCE

FEATURE
→ BOTTLENECK

ENTHUSIASM
→ FALSIFIABLE TEST

BUILD COST
→ ATTENTION COST

MOAT
→ COMPOUNDING

ONLY YOU
→ RIGHT TO WIN

AUTOMATION RATE
→ EXCEPTION ECONOMICS

YES BY DEFAULT
→ NO UNTIL EVIDENCE

INTUITION
→ CALIBRATED JUDGMENT
```

The most important question is not:

> Can AI build this?

It is:

> **Should this transaction exist, and what evidence would make us confident enough to spend scarce attention on it?**

And after that:

> **Does repeatedly winning this transaction create a stronger position?**

The goal is not to stop building.

The goal is to make building the consequence of evidence.
