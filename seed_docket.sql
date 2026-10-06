-- Docket seed data: fully synthetic, matches the clickable demo exactly.
-- Run in Snowsight or let CoCo run it. Change the warehouse name if needed.

CREATE DATABASE IF NOT EXISTS DOCKET;
CREATE SCHEMA IF NOT EXISTS DOCKET.CORE;
USE SCHEMA DOCKET.CORE;

CREATE OR REPLACE TABLE MEMBERS (member_id STRING, name STRING, age INT, sex STRING, plan STRING, pcp STRING);
INSERT INTO MEMBERS VALUES
 ('M-20417','Lorraine Pembury',71,'F','Bluestem Advantage HMO (Medicare Advantage)','K. Iyer, MD'),
 ('M-31188','Marcus Thorne-Ibarra',52,'M','Bluestem Exchange Silver (QHP, FFE)','J. Halvorsen, NP');

CREATE OR REPLACE TABLE ENCOUNTERS (encounter_id STRING, member_id STRING, encounter_type STRING, admit_date DATE, discharge_date DATE, admit_source STRING, principal_dx STRING);
INSERT INTO ENCOUNTERS VALUES
 ('ENC-55120','M-20417','Inpatient','2026-09-14','2026-09-20','Emergency department','I50.23 Acute on chronic systolic heart failure');

CREATE OR REPLACE TABLE MEDICAL_CLAIMS (claim_id STRING, member_id STRING, service_date DATE, claim_type STRING, code STRING, dx STRING, detail STRING);
INSERT INTO MEDICAL_CLAIMS VALUES
 ('CLM-ED-53877','M-20417','2026-05-02','ED','REV 0450','J44.1','COPD with acute exacerbation'),
 ('CLM-ED-54610','M-20417','2026-07-19','ED','REV 0450','R06.00','Dyspnea'),
 ('CLM-HH-56002','M-20417','2026-09-24','HOME_HEALTH','REV 0551','I50.22','Northgate Home Health, skilled nursing, 3 visits'),
 ('CLM-PT-0912','M-31188','2026-09-12','PT','CPT 97110','M54.16','Therapeutic exercise'),
 ('CLM-PT-0919','M-31188','2026-09-19','PT','CPT 97110','M54.16','Therapeutic exercise');

CREATE OR REPLACE TABLE RX_FILLS (fill_id STRING, member_id STRING, fill_date DATE, drug STRING, strength STRING, days_supply INT);
INSERT INTO RX_FILLS VALUES
 ('RX-FUR-0830','M-20417','2026-08-30','furosemide','20 mg',30),
 ('RX-LIS-0809','M-20417','2026-08-09','lisinopril','20 mg',30),
 ('RX-LIS-0926','M-20417','2026-09-26','lisinopril','20 mg',30),
 ('RX-NAP-0908','M-31188','2026-09-08','naproxen','500 mg',30);

CREATE OR REPLACE TABLE OBSERVATIONS (obs_id STRING, member_id STRING, obs_date DATE, test STRING, value STRING, flag STRING);
INSERT INTO OBSERVATIONS VALUES
 ('OBS-ECHO-0916','M-20417','2026-09-16','LVEF (echo)','30 %',NULL),
 ('OBS-ECHO-2303','M-20417','2023-03-11','LVEF (echo)','45 %',NULL),
 ('OBS-K-0919','M-20417','2026-09-19','Potassium','5.3 mmol/L','High');

CREATE OR REPLACE TABLE CONDITIONS (member_id STRING, code STRING, description STRING, charlson_weight INT);
INSERT INTO CONDITIONS VALUES
 ('M-20417','I50.22','Chronic systolic heart failure',2),
 ('M-20417','J44.9','COPD',2),
 ('M-20417','E11.9','Type 2 diabetes without complications',1),
 ('M-20417','I10','Essential hypertension',0),
 ('M-31188','M54.16','Lumbar radiculopathy',0);

CREATE OR REPLACE TABLE ALLERGIES (member_id STRING, status STRING, last_reviewed DATE);
INSERT INTO ALLERGIES VALUES ('M-20417','NKDA','2026-09-14');

CREATE OR REPLACE TABLE PA_REQUESTS (request_id STRING, member_id STRING, received DATE, priority STRING, item STRING, prescriber_specialty STRING);
INSERT INTO PA_REQUESTS VALUES
 ('PA-26-10021','M-20417','2026-10-02','Standard','Sacubitril/valsartan 24/26 mg BID','Cardiology'),
 ('PA-26-09877','M-31188','2026-10-01','Standard','CPT 72148 MRI lumbar spine w/o contrast','Primary care');

-- Unstructured documents (notes, synthetic plan policies, label excerpt)
CREATE OR REPLACE TABLE DOCS (doc_id STRING, member_id STRING, doc_type STRING, doc_date DATE, text STRING);
INSERT INTO DOCS VALUES
 ('DOC-DS-0920','M-20417','Discharge summary','2026-09-20','Admitted 09/14/2026 via ED. Discharged 09/20/2026. Acute on chronic HFrEF exacerbation. Discharge medications: Increase furosemide to 40 mg PO BID. Discontinue lisinopril. Begin sacubitril/valsartan 24/26 mg BID once authorization is obtained. Social: Lives alone. Daughter visits on weekends. Home health referral placed.'),
 ('DOC-CARD-0930','M-20417','Cardiology note','2026-09-30','Seen 10 days after discharge for HFrEF. Dyspnea walking one block; NYHA class III symptoms. Plan: start sacubitril/valsartan, PA submitted. Patient unsure which furosemide dose she is taking. Recheck BMP in 1 week.'),
 ('DOC-ED-241103','M-20417','ED note','2024-11-03','Lip and tongue swelling, onset about 2 hours after morning lisinopril dose. Also ate shrimp the previous evening. Treated with diphenhydramine; resolved. Impression: angioedema, etiology unclear (ACE inhibitor vs food). Recommend PCP review of lisinopril.'),
 ('DOC-PCP-0908','M-31188','Primary care note','2026-09-08','Low back pain for 10 days radiating to left leg. Numbness lateral left foot. Strength 5/5 bilaterally. No bowel or bladder changes. No fever. No history of cancer. Plan: naproxen 500 mg BID, refer to physical therapy.'),
 ('DOC-PCP-0929','M-31188','Primary care note','2026-09-29','Pain persists, 6/10. Attended 2 PT sessions. Numbness unchanged. Strength 5/5 bilaterally. Plan: request lumbar MRI.'),
 ('POL-CM-07',NULL,'Plan policy','2026-01-01','§3 Eligibility: member is eligible for 30-day transitional complex care management when the LACE index at discharge is 10 or higher. §5 Coordination: receipt of home health services does not preclude enrollment; the care manager must contact the agency within 3 business days.'),
 ('POL-RX-HF-12',NULL,'Plan policy','2026-01-01','§2 Sacubitril/valsartan is covered when: (a) heart failure with LVEF <= 40% documented within 12 months; (b) NYHA class II-IV; (c) prescribed by or with a cardiologist. §4 Safety: no concomitant ACE inhibitor; ACE inhibitor stopped at least 36 hours before first dose.'),
 ('POL-IMG-SP-04',NULL,'Plan policy','2026-01-01','§2 Lumbar MRI is medically necessary when (a) at least 6 weeks of documented conservative therapy has failed, or (b) a red flag is documented: progressive or severe neurologic deficit, cauda equina symptoms, suspected infection or malignancy.'),
 ('LBL-SACVAL',NULL,'FDA label §4','2025-05-01','Sacubitril and valsartan tablets are contraindicated: in patients with hypersensitivity to any component; in patients with a history of angioedema related to previous ACE inhibitor or ARB therapy; with concomitant use of ACE inhibitors. Do not administer within 36 hours of switching from or to an ACE inhibitor; with concomitant use of aliskiren in patients with diabetes.');
