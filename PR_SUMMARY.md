## Summary

This branch prepares the repository for the Nature Scientific Data submission with three sets of improvements:

### 1. Documentation, error fixes, and contextual clarity (`bec0587`)

**All 7 notebooks:**
- Updated Colab badge URLs from `deepakri201/NLSTNatureSciData` → `ImagingDataCommons/NLSTNatureSciData`
- Expanded introductory cells with Zenodo concept DOI links and collection descriptions
- Added `## Summary` conclusion cells interpreting results

**Specific fixes:**
- `parseSEGandSR.ipynb`: fixed "Vizualize" typo; removed empty trailing cell
- `NLSTSegvsNLSTSybil.ipynb`: fixed "NLSTSEg" typo; removed empty trailing cell
- `NLSTSegVsTS.ipynb`: removed empty trailing cell
- `createNLSTSybil.ipynb`: added missing `#` title heading; removed unused `drive.mount('/content/gdrive')` and its stale output; removed duplicate `import os` and `import numpy as np`
- `technicalCompliance.ipynb`: removed two debug-only cells (commented-out `os.environ` PATH assignment, failed `dciodvfy` command-not-found output)

**New files:**
- `README.md`: expanded with analysis results collection table (IDC `analysis_result_id` names and Zenodo concept DOIs), Prerequisites, and Suggested Reading Order
- `requirements.txt`: documents package versions used at publication time

### 2. Reduce BigQuery dependency; document requirements (`5bc0eb2`)

- `createNLSTSeg.ipynb`, `createNLSTSybil.ipynb`: removed unused `google-cloud-bigquery` and `google-cloud-storage` imports (these notebooks never called the BigQuery API)
- `NLSTSegVsTS.ipynb`: fully replaced BigQuery `dicom_all` query with an `idc-index` `seg_index` JOIN — verified correct (575 matching series); replaced `gsutil cp` downloads with `idc_client.download_from_selection()`; removed stale GCS bucket upload; GCP account no longer required for this notebook
- `README.md`: added table clarifying which notebooks require BigQuery and why, and which do not

### 3. Support local execution outside Google Colab (`0093dfe`)

- All notebooks with BigQuery: replaced hardcoded `from google.colab import auth; auth.authenticate_user()` with a conditional that uses Colab auth on Colab and [Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials) (`gcloud auth application-default login`) when running locally
- `requirements.txt`: added previously missing dependencies — `nibabel`, `google-cloud-bigquery`, `seaborn`, `tqdm` — and local install instructions
