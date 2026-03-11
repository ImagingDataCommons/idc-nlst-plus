SELECT
  dicom_all.PatientID AS PatientID,
  dicom_all.StudyInstanceUID AS StudyInstanceUID,
  value,
  measurements.Units.CodeMeaning AS units,
  Quantity.CodeMeaning AS quantity,
  findingSite.CodeMeaning AS findingSite,
  lateralityModifier.CodeMeaning AS laterality,
  CONCAT(dicom_all.SeriesInstanceUID,"-",dicom_all.SeriesNumber) AS segmentationAndSegment,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=",StudyInstanceUID,"&SeriesInstanceUIDs=",sourceSegmentedSeriesUID,",",dicom_all.SeriesInstanceUID) AS viewer_url
FROM
  `bigquery-public-data.idc_v18.quantitative_measurements` AS measurements
JOIN
  `bigquery-public-data.idc_v18.dicom_all` AS dicom_all
ON
  measurements.segmentationInstanceUID = dicom_all.SOPInstanceUID
WHERE
  dicom_all.analysis_result_id = "TotalSegmentator-CT-Segmentations"