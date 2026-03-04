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

- A **Google Cloud Platform (GCP) project** with BigQuery API enabled (for querying IDC metadata)
- A Google account for Colab authentication
- No local software installation is required — all dependencies are installed within the notebooks

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
