#!/bin/bash

## This bash script is meant to be run after qa/automated_tests is run and has generated screenshots for all the tests.

THE_PATH=$1
AUTOMATED_TESTS=$2

echo THE_PATH=$THE_PATH
echo AUTOMATED_TESTS=$AUTOMATED_TESTS

## Global variables
test_count=0
minor_fail=0
major_fail=0
pass=0

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


##  For each baseline image, run ImageMagick Compare. Run first with no fuzzy. If they don't match
##  then run a second time with fuzzy in case there are minor color differences. Save test results in an array. 

for f in "$THE_PATH"/qa/test_scripts/baselines/$test_resolution/*.png; do
    start_test_time=$(date +%s.%N)
    png_file=${f##*/}
    if test -e "$AUTOMATED_TESTS/$png_file" ; then
    	    test_count=$((test_count+1))
	    compare_cmd="compare -metric AE '$f' '$AUTOMATED_TESTS/$png_file' /dev/null 2>&1"
#	    echo $compare_cmd
	    imgdiff=$(compare -metric AE "$f" "$AUTOMATED_TESTS/$png_file" /dev/null 2>&1)
#           echo original imgdiff = $imgdiff
	    status2=$?
            imgdiff=`echo $imgdiff|awk '{print($1)}'`
	 #  echo
#           echo new imgdiff = $imgdiff
         #  echo `expr "$imgdiff" : ''`
	 #  echo
	    if [ $status2 -eq 0 ]; then {
		    if [ $imgdiff -eq 0 ]; then {
	    		end_test_time=$(date +%s.%N)
	    		test_duration=$(echo "$end_test_time - $start_test_time" | bc)
	   		test_duration=${test_duration:0:5}   
			pass=$(($pass+1))
			N_ARRAY[test_count]=$png_file
			D_ARRAY[test_count]=$test_duration
			R_ARRAY[test_count]="pass"
		    }
		    else {
			
			imgdiff_fuzz=$(compare -metric AE -fuzz $fuzz "$f" "$AUTOMATED_TESTS"/$png_file /dev/null 2>&1)
			#echo compare -metric AE -fuzz $fuzz "$f" "$AUTOMATED_TESTS"/$png_file /dev/null 2>&1
			#echo imgdiff_fuzz=$imgdiff_fuzz

	    		end_test_time=$(date +%s.%N)
	    		test_duration=$(echo "$end_test_time - $start_test_time" | bc)
	   		test_duration=${test_duration:0:5}  
		    
			if [ $imgdiff_fuzz -ge 0 -a $imgdiff_fuzz -lt 401 ]; then {
				echo Minor fail: "$f"
				minor_fail=$(($minor_fail+1))
				N_ARRAY[test_count]=$png_file
				D_ARRAY[test_count]=$test_duration
				R_ARRAY[test_count]="pass"
		   	 }
		   	elif [ $imgdiff_fuzz -gt 400 ]; then 
				echo MAJOR FAIL: "$f"
				major_fail=$(($major_fail+1))
				N_ARRAY[test_count]=$png_file
				D_ARRAY[test_count]=$test_duration
				R_ARRAY[test_count]="fail"
				M_ARRAY[test_count]="Image diff > 400 px even with $fuzz difference: $imgdiff_fuzz"
			fi
		    }
		    fi
	     }
             else
		#echo "Compare error when running:"		  
		#echo "$compare_cmd"  
		major_fail=$(($major_fail+1))
		N_ARRAY[test_count]=$png_file
		D_ARRAY[test_count]=$test_duration
		R_ARRAY[test_count]="fail"
		M_ARRAY[test_count]="Major fail when trying to do comparison."
	     fi
         
     else
	echo "Skipping $png_file. Test generated png does not exist."
     fi

done

## Create the XML results file ##

trickplay_version=1.0
XML_FILE="$THE_PATH/gui-test-results/gui_test.xml"

[ -r $XML_FILE ] || exit 1

end_time=$(date +%s.%N)
total_test_time=$(echo "$end_time - $start_time" | bc)
total_test_time=${total_test_time:0:6} 

xml_open_tag_to_add="<testsuite name='com.trickplay.gui-test.engine' errors='$minor_fail' failures='$major_fail' tests='$test_count' time='$total_test_time'><properties><property name='trickplay.version' value='$trickplay_version' /></properties>"
xml_close_tag_to_add="</testsuite>"

echo $xml_open_tag_to_add 1>"$XML_FILE"

i=1
while [ $i -le $test_count ]; do
	if [ ${R_ARRAY[$i]} == 'pass' ]; then
		xml_pass_to_add="<testcase classname='com.trickplay.gui-test.engine' name='${N_ARRAY[$i]}' time='${D_ARRAY[$i]}'/>"
		echo $xml_pass_to_add 1>>"$XML_FILE"
	else
	echo fail_test=$i
		xml_failure_to_add="<testcase classname='com.trickplay.unit-test.engine' name='${N_ARRAY[$i]}' time='${D_ARRAY[$i]}'><failure type='failure'>'${M_ARRAY[$i]}'</failure></testcase>"
		echo $xml_failure_to_add 1>>"$XML_FILE"
	fi
	let i=i+1
done

## Dump Results to Console  ##
echo GUI Automated Tests Completed
echo
echo -e "PASS \t\t$pass"
echo -e "FAIL \t\t$major_fail"
echo -e "ERRORS  \t$minor_fail"
echo -e "TOTAL TESTS \t$test_count"
echo

echo $xml_close_tag_to_add 1>>"$XML_FILE"
exit 0
