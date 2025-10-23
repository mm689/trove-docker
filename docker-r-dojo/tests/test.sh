#!/bin/bash -e
set -o errexit

# Check the script can generate what it needs to
$(dirname $0)/test.r

echo "Checking all R packages can be loaded..."
LAMBDA_FLAG="$(which yum && echo "--lambda" || echo "")"
./package-install.r --validate $LAMBDA_FLAG

echo -n "Checking error messages are in English... "
Rscript -e 'intentional.typo()' 2>&1 | grep -q "could not find function"
echo "success!"
