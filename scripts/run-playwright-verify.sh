#!/bin/bash
SPEC=$1
RETRY=0
MAX=3

while [ $RETRY -lt $MAX ]; do
  npx playwright test "$SPEC" && { echo "PASS"; exit 0; }
  RETRY=$((RETRY + 1))
  echo "Attempt $RETRY/$MAX failed" >&2
done

echo "FAIL after $MAX attempts" >&2
exit 1
