--
--  Trickplay Automation Framework
-- Description: This framework takes the following:
--      1) Filename assigned to the variable test_file that contains a table with:
--          a) Filename: Name of the file with the code.
--          b) Checksum: MD5 Hash of the displayed image.
--          c) Active: Boolean on whether to include the test.
--      2) Filename that contains a function called generate_test_image that returns
--          code that generates an image.
--

-- Test package location
local test_resolution = screen.display_size[2]
print ("test_resolution =", test_resolution)
local test_folder = "all_tests_ubuntu"
local test_list_file = "all_tests_ubuntu_"..test_resolution..".txt"

-- Options to run one test, all tests or just the last 2
local automation_option_choices = { all_tests = 1, specific_test = 2, last_two_tests = 3 }
local automation_option = 1
local test_to_run =  89 -- if automation_option == 2

-- if option 2 then it prints test results in a JSON formatted table to be copied and pasted into
-- the package file.
-- It contains the generated checksum so  ensure that all tests pass before using this as a baseline.
local console_display_option_choices = { test_results = 1, dump_screensum = 2 }
local console_display_option = 1

-- Globals --
local test_list
local test_results = {}
local pass_count = 0
local fail_count = 0
local disabled_count = 0
local dump_screensum = {}

-- load and parse the test file into a table.
local function load_test_list ()
    local loaded_test_list = {}
    print (test_list_file)
    local tests_file_string = readfile ("packages/test_package_lists/"..test_list_file)

    local all_tests = json:parse(tests_file_string)


    if automation_option == automation_option_choices["last_two_tests"] then
        print ("Only running the last 2 tests...")
        local total_tests = #all_tests
        local temp_tests = {}
        temp_tests[1] = all_tests[total_tests - 1]
        temp_tests[2] = all_tests[total_tests]
        all_tests = temp_tests
    elseif automation_option == automation_option_choices["specific_test"] then
        print ("Only running test number "..test_to_run.."...")
        local total_tests = #all_tests
        local temp_tests = {}
        temp_tests[1] = all_tests[test_to_run]
        all_tests = temp_tests
    else
        print ("Running all tests...")
    end

    return all_tests
end

-- function that does pretty much everything
local function do_test (tests)
    local checksumValue
    local filename
    local master_screensum
    local test_active
    local view_generated = false
    local checksum_done = false
    local g
    local i = 1

    local next_test

    next_test = function()
        -- clean up all objects and garbage collect
        if view_generated == true and checksum_done == true  then
            screen:remove(g)
            g = nil

            checksum_done = false
            view_generated = false
        end

        test_active = tests[i]["active"]
        while(i <= #tests and test_active == "false") do
            print("Skipping test ",tests[i]["name"],"marked as inactive")
            disabled_count = disabled_count + 1
            i=i+1
            test_active = tests[i]["active"]
        end


        -- Generate the view
        if test_active == "true" then
            if checksum_done == false and view_generated == false  then
                filename = tests [i]["name"]
                master_screensum = tests[i]["checksum"]

                dofile("packages/"..test_folder.."/"..filename)
                -- Load the generated test image
                g = generate_test_image()
                screen:add(g)

                view_generated = true

            elseif view_generated == true then
            -- do a checksum and compare to master then save results in a table.
                local screenshot = devtools:screenshot(string.sub(filename,1, (string.len(filename)-4)))
                checksumValue = devtools:screensum()

                if checksumValue == master_screensum then
                    test_results[i] = "Pass"
                    pass_count = pass_count + 1
                else
                    test_results[i] = "Fail"
                    fail_count = fail_count + 1
                    print (filename..": "..test_results[i])
                    print ("Generated checksum = \t",checksumValue)
                    print ("Master checksum = \t", master_screensum)
                    print ("---------------------------------------------")
                end

                table.insert (dump_screensum, {filename, checksumValue, test_active})
                i = i + 1

                checksum_done = true
            end
        end

        if i > #tests then
        -- once all tests have been run, print results to the console.
            idle.on_idle = nil
            if console_display_option == console_display_option_choices["dump_screensum"] then
                local dump_string = "\n"
                for i=1, #dump_screensum do
                    dump_string = dump_string..string.format ("{\n\"name\": \"%s\",\n\"checksum\": \"%s\",\n\"active\": \"%s" , dump_screensum[i][1],  dump_screensum[i][2],  dump_screensum[i][3].."\"\n},\n")
                end
            print (dump_string)
            end

            print( "" )
            print("Tests completed")
            print("")
            print("Final Results")
            print( string.format( "PASSED       %4d (%d%%)" , pass_count , ( pass_count / #test_list ) * 100 ) )
            print( string.format( "FAILED       %4d (%d%%)" , fail_count , ( fail_count / #test_list ) * 100 ) )
            print( string.format( "NOT TESTED   %4d (%d%%)" , disabled_count , ( disabled_count / #test_list ) * 100 ) )
            print( string.format( "TOTAL           %4d" , #test_list ) )
            print( "" )
            exit()
        end

        dolater(next_test)
    end

    next_test()
end

-- Load the background
screen:add(Rectangle { size=screen.size, color="white" } )

screen:show()

-- main --
test_list = load_test_list ()
do_test(test_list)
