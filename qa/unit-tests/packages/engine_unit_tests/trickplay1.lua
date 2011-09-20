--[[
Filename: trickplay1.lua
Author: Peter von dem Hagen
Date: January 26, 2011
Description:  Verify that the trickplay properties all return their expected values.
			  Note: Most of the tests just verify that a value is returned and not 
			  what the specific value is. This is because these values would change 
			  based on the environment and set up of Trickplay.
--]]


-- Test Set up --

-- Tests --


function test_trickplay_version_exists ()
    assert_string( trickplay.version , "trickplay.version not returning value" )
end

function test_trickplay_production ()
    assert_false ( trickplay.production, "trickplay.production not returning false" )
end

function test_trickplay_profiling ()
    assert_true ( trickplay.profiling, "trickplay.profiling not returning false" )
end

function test_trickplay_libraries ()
    assert_table ( trickplay.libraries["clutter"],  "trickplay.libraries[clutter] ~= table" )
    assert_table ( trickplay.libraries["json"],  "trickplay.libraries[json] ~= table" )
    assert_table ( trickplay.libraries["openssl"],  "trickplay.libraries[openssl] ~= table" )
    assert_table ( trickplay.libraries["glib"],  "trickplay.libraries[glib] ~= table" )
    assert_table ( trickplay.libraries["jpeg"],  "trickplay.libraries[jpeg] ~= table" )
    assert_table ( trickplay.libraries["fontconfig"],  "trickplay.libraries[fontconfig] ~= table" )
    assert_table ( trickplay.libraries["lua"],  "trickplay.libraries[lua] ~= table" )
    assert_table ( trickplay.libraries["zlib"],  "trickplay.libraries[zlib] ~= table" )
    assert_table ( trickplay.libraries["expat"],  "trickplay.libraries[expat] ~= table" )
    assert_table ( trickplay.libraries["cairo"],  "trickplay.libraries[cairo] ~= table" )
    assert_table ( trickplay.libraries["gif"],  "trickplay.libraries[gif] ~= table" )
    assert_table ( trickplay.libraries["pango"],  "trickplay.libraries[pango] ~= table" )
    assert_table ( trickplay.libraries["tiff"],  "trickplay.libraries[tiff] ~= table" )
    assert_table ( trickplay.libraries["freetype"],  "trickplay.libraries[freetype] ~= table" )
    assert_table ( trickplay.libraries["png"],  "trickplay.libraries[png] ~= table" )
    assert_table ( trickplay.libraries["sqlite"],  "trickplay.libraries[sqlite] ~= table" )
    assert_table ( trickplay.libraries["curl"],  "trickplay.libraries[curl] ~= table" )
end

function test_trickplay_config_keys_exist ()
    assert_string ( trickplay.config["app_sources"] ,"trickplay app_sources not returning false" )
    assert_string ( trickplay.config["profile_id"] ,"trickplay profile_id not returning false" )
    assert_string ( trickplay.config["app_path"] ,"trickplay app_path not returning false" )
    assert_string ( trickplay.config["system_name"] ,"trickplay system_name not returning false" )
    assert_string ( trickplay.config["screen_height"] ,"trickplay screen_height not returning false" )
    assert_string ( trickplay.config["profile_name"] ,"trickplay profile_name not returning false" )
    assert_string ( trickplay.config["system_country"] ,"trickplay system_country not returning false" )
    assert_string ( trickplay.config["system_sn"] ,"trickplay system_sn not returning false" )
    assert_string ( trickplay.config["system_language"] ,"trickplay system_language not returning false" )
    assert_string ( trickplay.config["data_path"] ,"trickplay data_path not returning false" )
    assert_string ( trickplay.config["system_version"] ,"trickplay system_version not returning false" )
    assert_string ( trickplay.config["downloads_path"] ,"trickplay downloads_path not returning false" )
    assert_string ( trickplay.config["screen_width"] ,"trickplay screen_width not returning false" )
end

function test_trickplay_system_keys_exist ()
    assert_string ( trickplay.system["uuid"] ,"trickplay uuid not returning false" )
    assert_string ( trickplay.system["version"] ,"trickplay version not returning false" )
    assert_string ( trickplay.system["country"] ,"trickplay country not returning false" )
    assert_string ( trickplay.system["language"] ,"trickplay language not returning false" )
    assert_string ( trickplay.system["name"] ,"trickplay name not returning false" )
end

-- Test Tear down --













