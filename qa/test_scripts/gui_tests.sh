#!/bin/bash

## This bash script is meant to be run after qa/automated_tests is run and has generated screenshots for all the tests.

THE_PATH=$1
AUTOMATED_TESTS=$2

echo THE_PATH=$THE_PATH
echo AUTOMATED_TESTS=$AUTOMATED_TESTS

##Set Fuzz %
fuzz=60%

start_time=$(date +%s.%N)

## Determine the screen resolution of the screenshots ##

test_info=$(identify "$AUTOMATED_TESTS/00001_rectangle_basic.png" )


if `echo ${test_info} | grep "1080" 1>/dev/null 2>&1`
 then
   echo "Test resolution is 1080."
  test_resolution="1080"
elif `echo ${test_info} | grep "720" 1>/dev/null 2>&1`
 then
   echo "Test resolution is 720."
   test_resolution="720"
elif `echo ${test_info} | grep "540" 1>/dev/null 2>&1`
 then
   echo "Test resolution is 540."
   test_resolution="540"
 else
  echo "Test is neither 540, 720 or 1080. Exiting."
  exit 1
fi


# Parallelize image comparisons
RESULTS=$(find "${THE_PATH}/qa/test_scripts/baselines/${test_resolution}" -maxdepth 1 -name '*.png' -print0 | xargs -0 -n1 -P2 "${THE_PATH}/qa/test_scripts/compare_images.sh" "${AUTOMATED_TESTS}")
PASSES=$(fgrep -c :pass: <<< "${RESULTS}")
FAILS=$(fgrep -c :failure: <<< "${RESULTS}")
ERRORS=$(fgrep -c :error: <<< "${RESULTS}")
SKIP=$(fgrep -c :skip: <<< "${RESULTS}")
TOTAL=$(wc -l <<< "${RESULTS}")

## Create the XML results file ##

trickplay_version=1.0
mkdir -p "${THE_PATH}/gui-test-results"
XML_FILE="$THE_PATH/gui-test-results/gui_test.xml"

end_time=$(date +%s.%N)
total_test_time=$(echo "$end_time - $start_time" | bc)
total_test_time=${total_test_time:0:6}

>"${XML_FILE}" echo "<testsuite name='com.trickplay.gui-test.engine' errors='$ERRORS' failures='$FAILS' skipped='$SKIP' tests='$TOTAL' time='$total_test_time'><properties><property name='trickplay.version' value='$trickplay_version' /></properties>"

IFS=$'\n'
for RESULT in $RESULTS; do
    IFS=':' read -a PARSED_RESULT <<< "$RESULT"

    if [ ${PARSED_RESULT[2]} == 'pass' ]; then
        >>"${XML_FILE}" echo "<testcase classname='com.trickplay.gui-test.engine' name='${PARSED_RESULT[0]}' time='${PARSED_RESULT[1]}' />"
    elif [ ${PARSED_RESULT[2]} == 'skip' ]; then
        >>"${XML_FILE}" echo "<testcase classname='com.trickplay.gui-test.engine' name='${PARSED_RESULT[0]}' time='${PARSED_RESULT[1]}'><skipped /></testcase>"
    elif [ ${PARSED_RESULT[2]} == 'error' ]; then
        >>"${XML_FILE}" echo "<testcase classname='com.trickplay.gui-test.engine' name='${PARSED_RESULT[0]}' time='${PARSED_RESULT[1]}'><error type='error' message='${PARSED_RESULT[3]}'>${PARSED_RESULT[3]}</error></testcase>"
    else
        >>"${XML_FILE}" echo "<testcase classname='com.trickplay.gui-test.engine' name='${PARSED_RESULT[0]}' time='${PARSED_RESULT[1]}'><failure type='failure' message='${PARSED_RESULT[3]}'>${PARSED_RESULT[3]}</failure></testcase>"
    fi
done

## Dump Results to Console  ##
echo GUI Automated Tests Completed

>>"$XML_FILE" echo '</testsuite>'
