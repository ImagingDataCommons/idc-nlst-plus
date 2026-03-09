-- NLST-Sybil
-- Here we query to get extra counts of number of bounding boxes per slice, 
-- and geometry like the width and height of the bounding boxes 

WITH counts AS (
  SELECT
    ReferencedSeriesInstanceUID,
    COUNT(DISTINCT ReferencedSOPInstanceUID) AS num_referenced_sops,
    COUNT(DISTINCT trackingUniqueIdentifier) AS num_tracking_uids
  FROM
    `idc-external-018.idc_v23_public_dashboards.nlst_sybil_bbox_measurements`
  GROUP BY
    ReferencedSeriesInstanceUID
)

SELECT DISTINCT
  m.*,
  -- Get the SeriesNumber and SeriesDescription of the ReferencedSeries
  dicom_all.SeriesNumber,
  dicom_all.SeriesDescription,
  -- Get the count of the number of bounding boxes per SOPInstanceUID
  COUNT(*) OVER (PARTITION BY m.ReferencedSOPInstanceUID) AS count_referenced_sop,
  -- viewer url 
  CONCAT(
    'https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=',
    m.StudyInstanceUID
  ) AS viewer_url,
  CONCAT('https://viewer.imaging.datacommons.cancer.gov/v3/viewer/?StudyInstanceUIDs=',
    m.StudyInstanceUID, '&SeriesInstanceUIDs=',
    m.ReferencedSeriesInstanceUID,',', m.SeriesInstanceUID) AS series_viewer_url,
  -- Get the counts from the first query 
  c.num_referenced_sops,
  c.num_tracking_uids,
  -- Calculate the width, height, area, and centers of the bounding boxes 
  GREATEST(m.x0, m.x1, m.x2, m.x3) - LEAST(m.x0, m.x1, m.x2, m.x3) AS width,
  GREATEST(m.y0, m.y1, m.y2, m.y3) - LEAST(m.y0, m.y1, m.y2, m.y3) AS height,
  (GREATEST(m.x0, m.x1, m.x2, m.x3) - LEAST(m.x0, m.x1, m.x2, m.x3)) *
  (GREATEST(m.y0, m.y1, m.y2, m.y3) - LEAST(m.y0, m.y1, m.y2, m.y3)) AS area,
  (LEAST(m.x0, m.x1, m.x2, m.x3) +
   (GREATEST(m.x0, m.x1, m.x2, m.x3) - LEAST(m.x0, m.x1, m.x2, m.x3)) / 2) AS center_x,
  (LEAST(m.y0, m.y1, m.y2, m.y3) +
   (GREATEST(m.y0, m.y1, m.y2, m.y3) - LEAST(m.y0, m.y1, m.y2, m.y3)) / 2) AS center_y,
FROM
  `idc-external-018.idc_v23_public_dashboards.nlst_sybil_bbox_measurements` AS m
LEFT JOIN
  counts AS c
USING (ReferencedSeriesInstanceUID)
LEFT JOIN
  `bigquery-public-data.idc_v23.dicom_all` AS dicom_all
ON
  dicom_all.SeriesInstanceUID = m.ReferencedSeriesInstanceUID
ORDER BY 
  m.PatientID, 
  m.StudyInstanceUID, 
  m.ReferencedSeriesInstanceUID, 
  m.trackingIdentifier
