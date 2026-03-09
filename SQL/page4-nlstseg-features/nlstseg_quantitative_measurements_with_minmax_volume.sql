SELECT DISTINCT
  # measurements.*, 
  PatientID, 
  StudyInstanceUID,
  ReferencedSeriesDescription, 
  ReferencedSeriesNumber, 
  SOPInstanceUID, 
  SeriesInstanceUID, 
  SeriesDescription,
  segmentationSeriesUID, 
  sourceSegmentedSeriesUID,
  COUNT(Value) OVER (PARTITION BY sourceSegmentedSeriesUID) AS num_lesions,
  MIN(Value) OVER (PARTITION BY sourceSegmentedSeriesUID) AS min_value,
  MAX(Value) OVER (PARTITION BY sourceSegmentedSeriesUID) AS max_value,
  viewer_url,
  series_viewer_url,
FROM 
  `idc-external-018.idc_v23_public_dashboards.nlstseg_quantitative_measurements` as measurements
WHERE
  Quantity.CodeMeaning = "Volume from Voxel Summation"
ORDER BY 
  PatientID, 
  StudyInstanceUID,
  sourceSegmentedSeriesUID