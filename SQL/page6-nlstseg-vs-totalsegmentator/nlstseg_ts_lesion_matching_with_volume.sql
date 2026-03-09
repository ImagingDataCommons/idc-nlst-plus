# Join this lesion_matching table with the quantitative measurements table
# Then we can see if larger lesions affect the overlap with TS more 

# Here we have one row per lesion - aggregate the TS segments into a single row for simplicity. 
SELECT
  CAST(lm.PatientID AS STRING) AS PatientID, 
  lm.StudyInstanceUID,
  lm.segmented_SeriesInstanceUID,
  lm.NLSTSeg_SeriesInstanceUID,
  lm.Lesion,
  lm.NLSTSeg_Segment,
  -- Aggregate all TS-related info into one array (no Percentage)
  # ARRAY_AGG(DISTINCT lm.TS_Segment ORDER BY lm.TS_Segment) AS TS_segments,
  STRING_AGG(DISTINCT lm.TS_Segment ORDER BY lm.TS_Segment) AS TS_segments,
  -- per series match 
  # ARRAY_AGG(lm.per_series_match ORDER BY lm.TS_Segment) AS per_series_match,
  MIN(lm.per_series_match) AS per_series_match,
  quant.Value AS lesion_volume,
  -- study level url 
  CONCAT(
    "https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=",
    lm.StudyInstanceUID
  ) AS viewer_url,
  -- series level url 
    CONCAT(
    "https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=",
    lm.StudyInstanceUID, "&SeriesInstanceUID=",lm.segmented_SeriesInstanceUID,",",lm.NLSTSeg_SeriesInstanceUID, ",", ANY_VALUE(lm.TS_SeriesInstanceUID)
  ) AS series_viewer_url
FROM
  # `idc-external-018.idc_v23_public_dashboards.nlstseg_ts_lesion_matching` AS lm
  `idc-external-018.idc_v23_public_dashboards.nlstseg_ts_lesion_matching2` AS lm
JOIN
  `idc-external-018.idc_v23_public_dashboards.nlstseg_quantitative_measurements` AS quant
ON
  lm.NLSTSeg_SeriesInstanceUID = quant.segmentationSeriesUID
  AND lm.Lesion = quant.trackingIdentifier
WHERE
  quant.Quantity.CodeMeaning = "Volume from Voxel Summation"
GROUP BY
  lm.PatientID,
  lm.StudyInstanceUID,
  lm.segmented_SeriesInstanceUID,
  lm.NLSTSeg_SeriesInstanceUID,
  lm.Lesion,
  lm.NLSTSeg_Segment,
  quant.Value
ORDER BY 
  lm.PatientID, 
  lm.StudyInstanceUID, 
  lm.segmented_SeriesInstanceUID, 
  lm.Lesion