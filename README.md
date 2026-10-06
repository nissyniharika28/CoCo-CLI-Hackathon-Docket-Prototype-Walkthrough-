# Docket: an evidence courtroom for Member 360

**Team Docket Rocket** · CoCo CLI Hackathon (GCC Edition)
**Problem statement:** Patient and Member 360 and Clinical or Regulatory Document Copilot

Docket is a Patient/Member 360 copilot that puts every AI claim on trial. Two agents argue from cited EHR, claims, pharmacy and policy records, a rule-based Clerk strikes anything a source doesn't support, and a Judge issues a traceable ruling with the specific reason that CMS-0057-F requires.

![Docket trial view](media/screenshot-trial.png)

## Links

- **Live prototype:** `https://<your-github-username>.github.io/<repo-name>/` (after enabling GitHub Pages, see below)
- **Demo video:** [media/Docket-demo-walkthrough.mp4](media/Docket-demo-walkthrough.mp4)
- **Submission deck:** [docs/Docket-Submission.pdf](docs/Docket-Submission.pdf)

## How it works

| Role | What it does |
|---|---|
| **Advocate** | An agent that argues for the motion (for example, approve a prior authorization), citing record IDs |
| **Challenger** | An agent that argues against it from the same evidence |
| **Clerk** | A deterministic tool, not a model. It checks every statement against its cited source |
| **Judge** | Rules only on what survives, and states what evidence would change the ruling |

The Clerk raises four objections:

| Objection | Test | Effect |
|---|---|---|
| Hearsay | The statement cites no record | Struck |
| Not supported | The cited record doesn't contain the claimed fact | Struck |
| Stale | Evidence is outside the policy's time window | No weight |
| Conflict | Two records disagree about the same fact | Blocks approval |

The Judge can grant, hold, or send a request back for records. It never issues a denial; adverse decisions go to a licensed reviewer with a drafted specific reason. Risk uses the published LACE readmission index (van Walraven et al., CMAJ 2010), so every point traces to a record.

## Demo cases (all synthetic)

| Case | Ruling | Deciding evidence |
|---|---|---|
| Care management enrollment | Granted | LACE 14 against a threshold of 10; new diuretic dose unfilled for 15 days |
| Heart-failure drug prior auth | Safety hold | Criteria met, but two record conflicts touch the label's contraindications |
| Lumbar MRI prior auth | Request records | 23 of 42 days of conservative therapy; a "progressive" claim struck as not supported |

## Architecture on Snowflake

1. **Sources:** synthetic EHR, medical and pharmacy claims, PA requests, notes, plan policies, drug label text
2. **Unify:** streams and dynamic tables build `MEMBER_360`; documents parsed into searchable chunks
3. **Retrieve:** a semantic view for Cortex Analyst, and Cortex Search over documents
4. **Trial:** Cortex Agents for the Advocate, Challenger and Judge; the Clerk is a Python UDF tool
5. **Act:** Streamlit app; Jira and Slack via MCP; a nightly task re-tries members with new records

## Repository contents

| Path | What it is |
|---|---|
| `index.html` | The clickable prototype: a single self-contained page |
| `snowflake/seed_docket.sql` | Synthetic seed data that matches the demo cases exactly |
| `docs/coco-runbook.md` | The CoCo prompts used for each phase: planning, development, execution, testing |
| `docs/Docket-Submission.pdf` | Submission deck |
| `media/` | Demo video and screenshot |

## Run it locally

Open `index.html` in any browser. There's nothing to install or build.

## Deploy with GitHub Pages

Settings → Pages → Build and deployment → Source: **Deploy from a branch** → Branch: **main**, folder **/ (root)** → Save. The site is live at `https://<username>.github.io/<repo-name>/` within a minute or two.

## Notes

- All members, providers, agencies and plan policies are fictional. No real patient data is used.
- The prototype replays recorded agent outputs; the Jira and Slack actions are simulated. The Snowflake build in `docs/coco-runbook.md` runs them live.
- Label text is quoted from the US prescribing information for sacubitril and valsartan tablets. Regulatory context: CMS Interoperability and Prior Authorization Final Rule (CMS-0057-F).
