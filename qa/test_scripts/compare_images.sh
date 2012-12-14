##  For each baseline image, run ImageMagick Compare. Run first with no fuzzy. If they don't match
##  then run a second time with fuzzy in case there are minor color differences. Save test results in an array.

FUZZ=60%
LIMIT=400

REF_IMG="${2}"
TEST_NAME=$(basename "${REF_IMG}")
TEST_IMG="${1}/${TEST_NAME}"
if test -e "${TEST_IMG}"; then
    start_test_time=$(date +%s.%N)
    imgdiff=$(compare -metric AE "${REF_IMG}" "${TEST_IMG}" /dev/null 2>&1)
    if [ $? -eq 0 ]; then
        # normalize scientific-notation results that compare can give
        imgdiff=$(perl -e "print ${imgdiff}")
        if [ $imgdiff -eq 0 ]; then
            end_test_time=$(date +%s.%N)
            test_duration=$(echo "$end_test_time - $start_test_time" | bc)
            test_duration=${test_duration:0:5}
            echo ${TEST_NAME%.png}:$test_duration:pass:$imgdiff no fuzz
        else
            imgdiff=$(compare -metric AE -fuzz $FUZZ "${REF_IMG}" "${TEST_IMG}" /dev/null 2>&1)
            imgdiff=$(perl -e "print ${imgdiff}")
            end_test_time=$(date +%s.%N)
            test_duration=$(echo "$end_test_time - $start_test_time" | bc)
            test_duration=${test_duration:0:5}
            if [ $imgdiff -ge 0 -a $imgdiff -le $LIMIT ]; then
                echo ${TEST_NAME%.png}:$test_duration:pass:$imgdiff fuzz
            else
                echo ${TEST_NAME%.png}:$test_duration:failure:Image diff "&gt;" ${LIMIT}px - ${imgdiff}px
            fi
        fi
    else
        echo ${TEST_NAME%.png}:$test_duration:error:Failure when trying to compare images ${REF_IMG} and ${TEST_IMG} - ${imgdiff}
    fi
else
    echo ${TEST_NAME%.png}:$test_duration:skip:Missing test image target ${TEST_IMG}
fi
