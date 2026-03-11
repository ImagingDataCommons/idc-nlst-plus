-- This query joins the NLSTSeg segmentations and features with the 
-- IDC clincal metadata for NLST 
-- To simplify things, we only include the features from the segmentations where there is 1 lesion. 

-- This query gets the SeriesInstanceUIDs of the SEG files
-- that have only 1 lesion 
WITH series_uid_list AS (
  SELECT
    segmented_SeriesInstanceUID,
    ANY_VALUE(PatientID) AS PatientID,
    ANY_VALUE(StudyInstanceUID) AS StudyInstanceUID,
    COUNT(DISTINCT SegmentNumber) AS num_lesions
  FROM
    `idc-external-018.idc_v23_public_dashboards.nlstseg_segmentations`
  GROUP BY
    segmented_SeriesInstanceUID
  HAVING
    COUNT(DISTINCT SegmentNumber) = 1
),

-- This gets the references for the segmentations 
seg_refs AS (
  SELECT
    d.PatientID,
    d.StudyInstanceUID,
    -- Unnest ReferencedSeriesSequence (array)
    ref_series.SeriesInstanceUID AS ReferencedSeriesInstanceUID,
    d.SOPInstanceUID AS SEG_SOPInstanceUID,
    d.SeriesInstanceUID AS SEG_SeriesInstanceUID,
    -- Unnest ReferencedInstanceSequence (array inside each entry)
    ref_inst.ReferencedSOPInstanceUID AS ReferencedSOPInstanceUID
  FROM 
    `bigquery-public-data.idc_v23.dicom_all` AS d
  LEFT JOIN UNNEST(d.ReferencedSeriesSequence) AS ref_series
  LEFT JOIN UNNEST(ref_series.ReferencedInstanceSequence) AS ref_inst
  WHERE 
    d.Modality = 'SEG' AND 
    analysis_result_id = "NLSTSeg" 
),


-- This joins the segmentations with the dicom_all InstanceNumber 
-- And only includes where there is 1 lesion 
joined AS (
  SELECT DISTINCT
    seg_refs.PatientID,
    seg_refs.StudyInstanceUID,
    seg_refs.ReferencedSeriesInstanceUID,
    seg_refs.ReferencedSOPInstanceUID,
    orig.InstanceNumber AS ReferencedInstanceNumber,
    # orig.StudyDate AS StudyDate
    CASE orig.StudyDate
      WHEN '1999-01-02' THEN 0
      WHEN '2000-01-02' THEN 1
      WHEN '2001-01-02' THEN 2
      ELSE 3
    END AS StudyDate_mapped, 
  FROM 
    seg_refs
  JOIN
    series_uid_list
  ON 
    series_uid_list.segmented_SeriesInstanceUID = seg_refs.ReferencedSeriesInstanceUID
  JOIN
    `bigquery-public-data.idc_v23.dicom_all` AS orig
  ON 
    seg_refs.ReferencedSOPInstanceUID = orig.SOPInstanceUID
  # WHERE
    # series_uid_list.num_lesions = 1
),


-- Get the IDC metadata 
-- This needs to be joined on the seg_refs - to get the instances that appear in the seg only!! 
dicom_mapped AS (
  SELECT DISTINCT
    dicom_all.PatientID,
    dicom_all.StudyInstanceUID,
    dicom_all.StudyDate,
    dicom_all.SeriesInstanceUID,
    dicom_all.SeriesDescription,
    dicom_all.SeriesNumber, 
    dicom_all.SOPInstanceUID,
    dicom_all.InstanceNumber,
    `Rows`,
    `Columns`,
    CASE StudyDate
      WHEN '1999-01-02' THEN 0
      WHEN '2000-01-02' THEN 1
      WHEN '2001-01-02' THEN 2
      ELSE 3
    END AS StudyDate_mapped,
    # COUNT(*) OVER (PARTITION BY SeriesInstanceUID) AS sop_count_per_series
  FROM 
    `bigquery-public-data.idc_v23.dicom_all` as dicom_all 
  JOIN
    seg_refs 
  ON
    seg_refs.ReferencedSOPInstanceUID = dicom_all.SOPInstanceUID
),



-- This gets the complete IDC metadata 
idc_metadata_mapped AS(
  SELECT DISTINCT
    dicom_mapped.PatientID AS PatientID,
    dicom_mapped.StudyInstanceUID,
    dicom_mapped.StudyDate,
    dicom_mapped.SeriesInstanceUID,
    dicom_mapped.SeriesDescription, 
    dicom_mapped.SeriesNumber, 
    dicom_mapped.SOPInstanceUID,
    dicom_mapped.Rows,
    dicom_mapped.Columns,
    # dicom_mapped.sop_count_per_series, -- number of SOPInstanceUIDs per series 
    ctab.study_yr,
    ctab.sct_slice_num, -- axial slice number, where the tumor is the largest 
    CASE ctab.sct_epi_loc -- lung lobe location of the tumor 
      WHEN '1' THEN "Right Upper Lobe" 
      WHEN '2' THEN "Right Middle Lobe"
      WHEN '3' THEN "Right Lower Lobe"
      WHEN '4' THEN "Left Upper Lobe"
      WHEN '5' THEN "Lingula"
      WHEN '6' THEN "Left Lower Lobe"
      WHEN '8' THEN "Other (Specify in comments)"
    END AS sct_epi_loc,
    CASE ctab.sct_margins -- margin information for the tumor 
      WHEN '1' THEN "Spiculated (Stellate)"
      WHEN '2' THEN "Smooth" 
      WHEN '3' THEN "Poorly defined"
      WHEN '9' THEN "Unable to determine"
    END AS sct_margins, 
    CASE ctab.sct_pre_att -- attentuation information for the tumor 
      WHEN '.M' THEN "Missing"
      WHEN '.N' THEN "Not applicable (sct_ab_desc is not 51)"
      WHEN '1' THEN "Soft Tissue"
      WHEN '2' THEN "Ground glass"
      WHEN '3' THEN "Mixed"
      WHEN '4' THEN "Fluid/water"
      WHEN '6' THEN "Fat"
      WHEN '7' THEN "Other"
      WHEN '9' THEN "Unable to determine"
    END AS sct_pre_att,
    CASE prsn.de_stag -- lung cancer stage 
      WHEN ".M" THEN "Missing"
      WHEN ".N" THEN "Not Applicable"
      WHEN "110" THEN "Stage IA"
      WHEN "120" THEN "Stage IB"
      WHEN "210" THEN "Stage IIA"
      WHEN "220" THEN "Stage IIB"
      WHEN "310" THEN "Stage IIIA"
      WHEN "320" THEN "Stage IIIB"
      WHEN "400" THEN "Stage IV"
      WHEN "888" THEN "TNM not available"
      WHEN "900" THEN "Occult Carcinoma"
      WHEN "994" THEN "Carcinoid, cannot be assessed"
      WHEN "999" THEN "Unknown, cannot be assessed"
      ELSE "Not Applicable"
    END AS de_stag,
    -- CAST(prsn.de_type AS STRING) AS de_type -- lung cancer type using ICD-03 codes 
    CASE prsn.de_type 
      WHEN ".M" THEN "Missing"
      WHEN ".N" THEN "Not Applicable"
      WHEN "8481"	THEN "Mucin-producing adenocarcinoma"
      WHEN "8490"	THEN "Signet ring cell carcinoma"
      WHEN "8071"	THEN "Squamous cell carcinoma, keratinizing"
      WHEN "8252"	THEN "Bronchiolo-alveolar carcinoma, non-mucinous"
      WHEN "8570"	THEN "Adenocarcinoma with squamous metaplasia"
      WHEN "8323"	THEN "Mixed cell adenocarcinoma"
      WHEN "8010"	THEN "Carcinoma in situ"
      WHEN "8050"	THEN "Papillary adenocarcinoma"
      WHEN "8042"	THEN "Oat cell carcinoma"
      WHEN "8254"	THEN "Bronchiolo-alveolar carcinoma, mixed mucinous and non-mucinous"
      WHEN "8046"	THEN "Non-small cell carcinoma"
      WHEN "8255"	THEN "Adenocarcinoma with mixed subtypes"
      WHEN "8072"	THEN "Squamous cell carcinoma, large cell, nonkeratizing"
      WHEN "8253"	THEN "Invasive mucinous adenocarcinoma"
      WHEN "8246"	THEN "Neuroendocrine carcinoma"
      WHEN "8070"	THEN "Squamous cell carcinoma"
      WHEN "8480"	THEN "Mucinous adenocarcinoma"
      WHEN "8000"	THEN "Neoplasm, malignant"
      WHEN "8013"	THEN "Large cell neuroendocrine carcinoma"
      WHEN "8045"	THEN "Combined small cell carcinoma"
      WHEN "8140"	THEN "Adenocarcinoma"
      WHEN "8560"	THEN "Adenosquamous carcinoma"
      WHEN "8550"	THEN "Acinar cell carcinoma"
      WHEN "8083"	THEN "Basaloid squamous cell carcinoma"
      WHEN "8012"	THEN "Large cell carcinoma"
      WHEN "8250"	THEN "Lepidic Adenocarcinoma"
      WHEN "8240"	THEN "Carcinoid tumor, malignant"
      WHEN "8041"	THEN "Small cell carcinoma"
    END AS de_type 
  FROM
    `bigquery-public-data.idc_v23_clinical.nlst_ctab` AS ctab
  JOIN
    `bigquery-public-data.idc_v23_clinical.nlst_prsn` AS prsn
  ON 
    prsn.dicom_patient_id = ctab.dicom_patient_id
  -- anchor tumor slice to SEG-referenced CT slice
  JOIN
    joined
  ON 
    joined.PatientID = ctab.dicom_patient_id
     AND joined.ReferencedInstanceNumber = ctab.sct_slice_num
     AND joined.StudyDate_mapped = ctab.study_yr
  -- lock metadata to the exact SOP
  JOIN
    dicom_mapped
  ON 
    dicom_mapped.PatientID = ctab.dicom_patient_id 
    AND dicom_mapped.StudyDate_mapped = ctab.study_yr 
    AND dicom_mapped.InstanceNumber = ctab.sct_slice_num 
  -- We need to exclude the ones where there is more than 1 lesion for a particular patient/study
  -- Reason is that even if 1 lesion in NLSTSeg, it could be large. And it could overlap the multiple lesions in the IDC metadata, 
  -- and therefore include metadata from multiple lesions accidentally.
  QUALIFY COUNT(*) OVER (PARTITION BY ctab.dicom_patient_id, ctab.study_yr) = 1
)


-- Now we join the IDC metadata with the segmentations metadata 
SELECT DISTINCT
  idc_metadata_mapped.*, 
  meas.trackingIdentifier as trackingIdentifier, 
  meas.Quantity, 
  meas.Value,
  meas.viewer_url AS viewer_url, 
  meas.series_viewer_url AS series_viewer_url 
FROM
  idc_metadata_mapped 
JOIN
  `idc-external-018.idc_v23_public_dashboards.nlstseg_quantitative_measurements` AS meas
ON
  idc_metadata_mapped.PatientID = meas.PatientID AND 
  idc_metadata_mapped.SeriesInstanceUID = meas.sourceSegmentedSeriesUID
ORDER BY 
  idc_metadata_mapped.PatientID, 
  idc_metadata_mapped.StudyInstanceUID,
  idc_metadata_mapped.StudyDate,
  idc_metadata_mapped.SeriesInstanceUID, 
  trackingIdentifier
