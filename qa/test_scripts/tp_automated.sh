#!/bin/bash

## Global variables

minor_fail=0
major_fail=0
pass=0

## Check for location of Trickplay generated files

echo
echo "* Starting fuzzy compare script for Trickplay Automated Test results * "
echo
TP_AUTOMATED_TESTS=${TP_AUTOMATED_TESTS:-0}
if [ ! ${TP_AUTOMATED_TESTS} = "0" ]; then
  echo "Environment variable TP_AUTOMATED_TESTS set."
  echo "Using $TP_AUTOMATED_TESTS folder for generated png files."
elif [ -d "generated_pngs" ]; then 
  echo "Using existing generated_png folder for generated png files."
  TP_AUTOMATED_TESTS=$PWD/generated_pngs
elif [ -L "automated_tests" ]; then
  echo "Using symbolic link to automated_tests folder for generated png files."
  TP_AUTOMATED_TESTS=$PWD/automated_tests
else
  echo "Could not find location of ATS result pngs files."
  echo "Please set environment variable TP_AUTOMATED_TESTS to location of png files or "
  echo "create a folder on this level called generated_pngs and copy generated files to it."
  echo
  echo "Exiting script..."
  echo
  exit 1
fi

## Check what resolution the test files are

test_info=$(identify $TP_AUTOMATED_TESTS/00001_rectangle_basic.png )

# echo $test_info


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

echo
echo "Copying generated test images to $PWD/$results_folder/generated_pngs"
echo

cp $TP_AUTOMATED_TESTS/*.png $PWD/$results_folder/generated_pngs
#status1=$?

echo "** Comparing generated images to baseline images using Compare **"
for f in $PWD/baselines/$test_resolution/*.png; do
    pngfile=${f##*/}

    if test -e $PWD/$results_folder/generated_pngs/$pngfile ; then
	    compare_cmd="compare -metric AE -fuzz 85% $f $PWD/$results_folder/generated_pngs/$pngfile /dev/null 2>&1"
	   # echo "$compare_cmd"
	    imgdiff=`compare -metric AE -fuzz 85% $f $PWD/$results_folder/generated_pngs/$pngfile /dev/null 2>&1`
	    status2=$?
	    if [ $status2 -eq 0 ]; then {
		    if [ $imgdiff -eq 0 ]; then {
			pass=$(($pass+1))
		    }
		    elif [ $imgdiff -gt 0 -a $imgdiff -lt 401 ]; then {
			echo "Minor fail: $f "
			# echo "imgdiff=$imgdiff"
			compare -metric AE -fuzz 85% $f $PWD/$results_folder/generated_pngs/$pngfile $PWD/$results_folder/results/minor_failures/$pngfile 2>&1
			minor_fail=$(($minor_fail+1))
		    }
		    elif [ $imgdiff -gt 400 ]; then {
			echo "Major fail: $f"
			# echo "imgdiff=$imgdiff"
			compare -metric AE -fuzz 85% $f $PWD/$results_folder/generated_pngs/$pngfile $PWD/$results_folder/results/major_failures/$pngfile 2>&1
			major_fail=$(($major_fail+1))
		    }
		    fi
	     }
             else  {
		echo "Compare error when running:"		  
		echo "$compare_cmd"  
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
