# Docket: 2-hour CoCo runbook

**Rule for today:** take a screenshot of every CoCo step, both the prompt and its result. Judges score CoCo evidence in each phase, so put the screenshots in a `evidence/` folder as you go.

| Time | Phase | Output |
|---|---|---|
| 0:00–0:15 | Planning | Ontology and design doc written by CoCo |
| 0:15–0:45 | Development | Data loaded, Member 360 view, search service |
| 0:45–1:10 | Development | Clerk citation checker and the cited-answer function |
| 1:10–1:25 | Execution | Scheduled task, plus one end-to-end run |
| 1:25–1:40 | Testing | Golden questions, plus a fake-citation test |
| 1:40–2:00 | Submit | Demo link, screenshots, 1-page write-up |

If a step stalls for more than 10 minutes, skip it and keep the screenshot of the attempt. The clickable demo covers the user experience.

---

## 1. Planning (CoCo prompt)
```
I'm building "Docket", a Member 360 copilot for a health plan. Two agents argue for and against a motion (care-management enrollment or a prior authorization) using only cited evidence. A Clerk strikes any statement whose citation doesn't support it, and a Judge rules on what survives. The Judge never denies; it routes adverse cases to a human with a specific reason (CMS-0057-F).
Read seed_docket.sql. Write docs/design.md with: the ontology (Member, Encounter, Claim, Fill, Observation, Condition, Allergy, PA Request, Document, Policy clause, Motion, Exhibit, Ruling), the data flow, and the agent roles. Keep it to one page.
```

## 2. Development: data and the 360 view
```
Run seed_docket.sql in my account. Then create a view DOCKET.CORE.MEMBER_360 that unions encounters, claims, fills, observations and docs into one timeline: member_id, event_date, source_system, record_id, summary.
Then create a view LACE_SCORE computing the LACE index for each inpatient encounter using van Walraven 2010 points (LOS 1/2/3 days=1/2/3, 4-6=4, 7-13=5, 14+=7; emergent admission=3; Charlson from CONDITIONS capped: >=4 -> 5; ED visits in prior 6 months capped at 4). Show the result for M-20417; it should be 14.
```
Expected: **LACE = 14** (4+3+5+2). If CoCo gets a different number, show that it was caught and fixed. That counts as testing evidence.

```
Create a Cortex Search service DOCKET.CORE.DOC_SEARCH over DOCS.text with attributes member_id, doc_id, doc_type. Test it with "lisinopril swelling" filtered to member M-20417.
```

## 3. Development: the Clerk and cited answers
```
Create a Python UDF CLERK_CHECK(claim STRING, cited_text STRING) returning an object {verdict, reason}:
- 'HEARSAY' if cited_text is null or empty
- 'NOT_SUPPORTED' if any number or date in the claim is missing from cited_text, or if an LLM entailment check (use AI_COMPLETE with a model available in my region) says the text doesn't support the claim
- otherwise 'ADMITTED'.
Test: CLERK_CHECK('neurologic deficit is progressive', <text of DOC-PCP-0929>) must return NOT_SUPPORTED.
```
```
Create a SQL function ASK_COURT(member_id, question) that retrieves the top 5 chunks from DOC_SEARCH plus that member's MEMBER_360 rows, asks AI_COMPLETE to answer only from them, citing record ids in [brackets], and returns 'No admitted evidence answers this' when nothing supports an answer. Run it for M-20417 with "Is she still taking lisinopril?"
```
If you have time, ask CoCo to make a Cortex Agent with DOC_SEARCH plus a semantic view as tools. If not, skip it.

## 4. Execution
```
Create a stream on RX_FILLS and a task DOCKET_NIGHTLY that runs at 02:00 Asia/Kolkata, and when the stream has data, re-computes LACE_SCORE and writes a row to a RULINGS_LOG table. Run it once now with EXECUTE TASK and show the log.
```
Optional, for the Streamlit bonus: `Scaffold a Streamlit in Snowflake app showing MEMBER_360 and an Ask box that calls ASK_COURT.`

## 5. Testing
```
Run these and make a pass/fail table:
1. LACE for M-20417 = 14
2. ASK_COURT('M-20417','What is her latest ejection fraction?') cites OBS-ECHO-0916 and says 30%
3. ASK_COURT('M-20417','What is her blood type?') returns the no-evidence message
4. CLERK_CHECK with an empty citation returns HEARSAY
5. CLERK_CHECK('LVEF is 45%', <OBS-ECHO-0916 row as text>) returns NOT_SUPPORTED
6. Conservative-therapy days for M-31188 from 2026-09-08 to 2026-10-01 = 23
```

## 6. Submit
- Clickable demo link (share it from the page's Share menu first)
- `evidence/` screenshots, one or more per phase
- One-paragraph pitch: *"Docket puts every AI claim on trial. Two agents argue opposite sides from Member 360 evidence, a deterministic Clerk strikes anything a source doesn't support, and the Judge rules only on what survives. It states what would change the ruling and never issues a denial. Risk is a published, hand-checkable score, never an opaque prediction."*
