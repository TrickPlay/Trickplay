#!/bin/bash

## Global variables

minor_fail=0
major_fail=0
pass=0


## Run trickplay

# find the location of the automated_tests
TP_AUTOMATED_TESTS=${TP_AUTOMATED_TESTS:-0}
if [ ${TP_AUTOMATED_TESTS} = "0" ]; then
    echo "Required environment variable TP_AUTOMATED_TESTS not set. Exiting"
    exit 1
else
    echo $TP_AUTOMATED_TESTS
fi

trickplay_loc=`which trickplay`
found_trickplay=$?
if [ $found_trickplay -ne 0 ]; then
    echo "cannot find executable trickplay. exiting"
    exit 1
else
    echo "executing `which trickplay`"
fi

trickplay $TP_AUTOMATED_TESTS

status=$?

# echo $status

if [ $status -eq 0 ]; then {
    echo "Trickplay completed successfully"
    echo
}
else {
    echo "Trickplay failed to run the Automated Tests. (status: $status). Exiting script..."
    exit 1
}
fi


## Check what resolution the test files are

test_info=$(identify $TP_AUTOMATED_TESTS/00001_rectangle_basic.png )

# echo $test_info


if `echo ${test_info} | grep "1080" 1>/dev/null 2>&1`
 then
   echo "Test resolution is 1080."
  test_resolution="1080"
elif `echo ${test_info} | grep "540" 1>/dev/null 2>&1` 
 then
   echo "Test resolution is 540."
   test_resolution="540"
 else
  echo "Test is neither 540 or 1080. Exiting."
  exit 1
fi


## Generate the test result folder structure

results_folder=TP_ATS_`date +%Y_%m_%d_%H_%M_%S`

# echo $results_folder

echo "Creating new folder:    $results_folder"
echo
mkdir $PWD/$results_folder
mkdir -p $PWD/$results_folder/results/minor_failures
mkdir -p $PWD/$results_folder/results/major_failures
mkdir -p $PWD/$results_folder/generated_pngs

echo "Copying generated test images to $PWD/$results_folder/generated_pngs"
echo

cp $TP_AUTOMATED_TESTS/*.png $PWD/$results_folder/generated_pngs
status1=$?

echo "Comparing generated images to baseline images ..."

for f in $PWD/baselines/$test_resolution/*.png; do
    pngfile=${f##*/}

    if test -e $PWD/$results_folder/generated_pngs/$pngfile ; then
	    compare_cmd="compare -metric AE -fuzz 95% $f $PWD/$results_folder/generated_pngs/$pngfile /dev/null 2>&1"
	    # echo "$compare_cmd"
	    imgdiff=`compare -metric AE -fuzz 95% $f $PWD/$results_folder/generated_pngs/$pngfile /dev/null 2>&1`
	    if [ $imgdiff -eq 0 ]; then {
		pass=$(($pass+1))
	    }
	    elif [ $imgdiff -gt 0 -a $imgdiff -lt 401 ]; then {
		echo "Minor fail: $f "
		# echo "imgdiff=$imgdiff"
		compare -metric AE -fuzz 95% $f $PWD/$results_folder/generated_pngs/$pngfile $PWD/$results_folder/results/minor_failures/$pngfile 2>&1
		minor_fail=$(($minor_fail+1))
	    }
	    elif [ $imgdiff -gt 400 ]; then {
		echo "Major fail: $f"
		# echo "imgdiff=$imgdiff"
		compare -metric AE -fuzz 95% $f $PWD/$results_folder/generated_pngs/$pngfile $PWD/$results_folder/results/major_failures/$pngfile 2>&1
		major_fail=$(($major_fail+1))
	    }
	    fi
   else
	   echo "Skipping $pngfile. Baseline matching test file was not generated."
   fi
done
echo
echo -e "\t\tTests Results"
echo -e "Pass = \t\t\t$pass"
echo -e "Minor Fail = \t\t$minor_fail"
echo -e "Major Fail = \t\t$major_fail"

#cd ..
exit 0
