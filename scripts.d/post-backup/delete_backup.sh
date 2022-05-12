#!/bin/bash
# Delete backup file from GCP.
if [[ -n "$DB_DUMP_DEBUG" ]]; then
  set -x
fi

#DB_DUMP_TARGET=gs://test_backup3
if [[ "${DB_DUMP_TARGET}" = "gs://*" ]]; then
  now_date=$(date +"%Y%m%d")
  gs_paths=$(gsutil ls $DB_DUMP_TARGET | grep -e "/$" | sed 's|'"${DB_DUMP_TARGET}"'||;s|/||g' )
  for gs_path in ${gs_paths}; do
    end_ts=$(date -d "$now_date" '+%s')
    start_ts=$(date -d "$gs_path" '+%s')
    diff=$(( ( end_ts - start_ts )/(60*60*24) ))
    if [ $diff -gt 14 ]; then
      echo "Deleting date older than 14 days $DB_DUMP_TARGET/$gs_path ..."
      gsutil -m rm -r $DB_DUMP_TARGET/$gs_path/
    else
      echo "Found path: $DB_DUMP_TARGET/${gs_path}, skipping..."
    fi
  done
  echo "Cleanning done on remote GCS..."
fi