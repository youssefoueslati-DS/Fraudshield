#!/usr/bin/env bash
# Download the IEEE-CIS Fraud Detection training data into data/raw/
# Before running: accept the competition rules on Kaggle and run `uv run kaggle auth login`
set -e

mkdir -p data/raw

uv run kaggle competitions download ieee-fraud-detection -f train_transaction.csv -p data/raw
uv run kaggle competitions download ieee-fraud-detection -f train_identity.csv -p data/raw

# Remove the zip copies Kaggle leaves behind (unzip first if needed)
for zip in data/raw/*.zip; do
  [ -e "$zip" ] || continue
  unzip -o -q "$zip" -d data/raw
  rm "$zip"
done

echo "Done:"
ls -lh data/raw
