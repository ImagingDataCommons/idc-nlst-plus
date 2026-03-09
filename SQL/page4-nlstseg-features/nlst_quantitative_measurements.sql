SELECT DISTINCT
  quant.*,
  dicom_all.StudyInstanceUID,
  dicom_all.SeriesNumber AS ReferencedSeriesNumber, 
  dicom_all.SeriesDescription AS ReferencedSeriesDescription,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=", dicom_all.StudyInstanceUID) as viewer_url,
  # CONCAT("https://viewer.imaging.datacommons.cancer.gov/viewer/", dicom_all.StudyInstanceUID,"?seriesInstanceUID=",quant.segmentationSeriesUID,",",dicom_all.SeriesInstanceUID) AS series_viewer_url,
  CONCAT("https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=", dicom_all.StudyInstanceUID,"&SeriesInstanceUIDs=",quant.segmentationSeriesUID,",",dicom_all.SeriesInstanceUID) AS series_viewer_url,
FROM
  `bigquery-public-data.idc_v23.quantitative_measurements` AS quant
JOIN
  `bigquery-public-data.idc_v23.dicom_all` AS dicom_all
ON
  quant.sourceSegmentedSeriesUID = dicom_all.SeriesInstanceUID
WHERE
  quant.SeriesDescription LIKE "NLSTSeg%"
