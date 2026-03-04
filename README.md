# NLSTNatureSciData

This repository holds the necessary scripts and demonstrations for our Nature Scientific Data manuscript on enhancing the [National Lung Screening Trial (NLST)](https://www.cancer.gov/types/lung/research/nlst) collection in the [NCI Imaging Data Commons (IDC)](https://portal.imaging.datacommons.cancer.gov/) with DICOM Segmentation (SEG) and Structured Report (SR) annotations.

## Analysis Results Collections

This work accompanies the following analysis results collections available in IDC:

| IDC analysis_result_id | Zenodo DOI | Description |
|------------|------------|-------------|
| **NLSTSeg** | [10.5281/zenodo.17362625](https://doi.org/10.5281/zenodo.17362625) | Expert tumor segmentations and radiomics features for NLST CT images |
| **NLST-Sybil** | [10.5281/zenodo.15643335](https://doi.org/10.5281/zenodo.15643335) | Expert annotations of tumor regions in the NLST CT images |
| **TotalSegmentator-CT-Segmentations** | [10.5281/zenodo.13900142](https://doi.org/10.5281/zenodo.13900142) | AI-driven enrichment of NCI Imaging Data Commons CT images with volumetric segmentations and radiomics features |

## Prerequisites

All notebooks are designed to run on **Google Colab**. To execute them, you will need:

- A **Google account** for Colab authentication
- No local software installation is required — all dependencies are installed within the notebooks

### BigQuery requirement

Most notebooks query IDC metadata using [Google BigQuery](https://cloud.google.com/bigquery). For these notebooks you will also need:

- A **Google Cloud Platform (GCP) project** with the BigQuery API enabled
- The project must have billing enabled (BigQuery queries against public IDC datasets are free within the [free tier](https://cloud.google.com/bigquery/pricing#free-tier), but a billing account is required)

The following notebooks require BigQuery:

| Notebook | Why BigQuery is needed |
|----------|------------------------|
| `UsageNotes/parseSEGandSR.ipynb` | Queries `dicom_all` and `quantitative_measurements` tables |
| `TechnicalValidation/validateNLSTSegVolume.ipynb` | Queries `quantitative_measurements` for radiomics features |
| `TechnicalValidation/technicalCompliance.ipynb` | Queries `dicom_all` for series metadata |
| `TechnicalValidation/consistencyChecks/NLSTSegvsNLSTSybil.ipynb` | Joins NLSTSeg and NLST-Sybil via nested DICOM reference fields in `dicom_all` |

The following notebook does **not** require BigQuery — it uses [`idc-index`](https://github.com/ImagingDataCommons/idc-index) instead:

| Notebook | How it accesses IDC |
|----------|---------------------|
| `TechnicalValidation/consistencyChecks/NLSTSegVsTS.ipynb` | Uses `idc-index` `seg_index` table (no GCP account needed) |

The DataRecords notebooks (`createNLSTSeg.ipynb`, `createNLSTSybil.ipynb`) do not query IDC metadata at runtime — they generate the DICOM files from source data.

## Repository Structure

<pre>
NLSTNatureSciData/
├── DataRecords/
│   ├── createNLSTSeg.ipynb   -- code to generate the NLSTSeg SEG and SR DICOM files
│   └── createNLSTSybil.ipynb -- code to generate the NLSTSybil SR DICOM files
├── TechnicalValidation/
│   ├── consistencyChecks/
│   │   ├── NLSTSegVsTS.ipynb        -- code to compare NLSTSeg lung lobe locations of the lesions with TotalSegmentator lung lobe locations
│   │   └── NLSTSegvsNLSTSybil.ipynb -- code to compare NLSTSeg lesion segmentations with the NLST-Sybil bounding boxes
│   ├── technicalCompliance.ipynb    -- code to ensure the files are true DICOM files
│   └── validateNLSTSegVolume.ipynb  -- code to compare the volume of the lesions in NLSTSeg using pyradiomics vs what the authors provided
├── UsageNotes/
│   └── parseSEGandSR.ipynb -- demonstration of how to download, read, and visualize the SEG and SR DICOM files
├── NLSTSeg_codes.csv       -- SNOMED CT codes for lesion types (Tumor, Nodule)
├── NLSTSeg_lung_codes.csv  -- SNOMED CT codes for anatomical lung regions
├── LICENSE
└── README.md
</pre>

## Suggested Reading Order

1. **Start here** — [UsageNotes/parseSEGandSR.ipynb](UsageNotes/parseSEGandSR.ipynb): Learn how to download, read, and visualize the SEG and SR files from IDC
2. **Data creation** — [DataRecords/createNLSTSeg.ipynb](DataRecords/createNLSTSeg.ipynb) and [DataRecords/createNLSTSybil.ipynb](DataRecords/createNLSTSybil.ipynb): Understand how the DICOM files were generated
3. **Validation** — The TechnicalValidation/ notebooks: See how the data was validated for DICOM compliance, volume accuracy, and cross-collection consistency

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Author

Deepa Krishnaswamy
Brigham and Women's Hospital
December 2025
