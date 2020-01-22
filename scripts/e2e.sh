#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x

CI_REF="${2:-master}"
DEFAULT_EXEC_CONTAINER_NAME="e2e-command-runner"
EXEC_CONTAINER_NAME="${4:-$DEFAULT_EXEC_CONTAINER_NAME}"

# Check stuff out
helm version
git clone https://github.com/fairwindsops/charts
cd charts
git remote add fw https://github.com/fairwindsops/charts
git getch fw master
git checkout
git fetch origin pull/$CIRCLE_PR_NUMBER/head:pr/$CIRCLE_PR_NUMBER && git checkout pr/$CIRCLE_PR_NUMBER


# Run pre scripts for charts
CI_DIR="ci"
SCRIPT_NAME="pre-test-script.sh"
SCRIPT="$CI_DIR/$SCRIPT_NAME"
CHANGED="$(git diff master --name-only incubator/*/ stable/*/ | awk -F"/" '{print $1"/"$2}' | sort -u)"

for chart in $CHANGED; do
  if test -f "$chart/$SCRIPT"; then
    "$chart/$SCRIPT"
  fi
done

ct install --config scripts/ct.yaml
