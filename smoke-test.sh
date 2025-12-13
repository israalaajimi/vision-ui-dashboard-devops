#!/bin/bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

if [ "$STATUS" = "200" ]; then
  echo "SMOKE TEST PASSED"
  exit 0
else
  echo "SMOKE TEST FAILED"
  exit 1
fi
