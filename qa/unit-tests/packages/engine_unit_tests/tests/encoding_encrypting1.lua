--[[
Filename: encoding_encrypting1.lua
Author: Peter von dem Hagen
Date: January 25, 2011
Description:  Verify that all the encoding, decoding and encrypting functions return the expected values.
--]]




-- Test Set up --
my_string = "Trickplay rizzocks the hizzouse."
secret_key = "trickplay"
bad_secret_key = "Trickplay"


-- Tests --

function test_Global_md5 ()
    assert_equal( md5(my_string) , "8f7eca0786369d7810835af9078231f1", "md5 of "..my_string.." returned "..md5(my_string).." Expected 8f7eca0786369d7810835af9078231f1")
    assert_not_nil( md5(my_string, true) , "md5 encrypt binary returned nil" )
end


function test_Global_sha1 ()
    assert_equal( sha1(my_string), "ac1c646cf12c60fad4ff35ece0a5f1ea7ba0dbca", "sha1 of ", my_string, " returned: ", sha1 (my_string), " Exptected: ac1c646cf12c60fad4ff35ece0a5f1ea7ba0dbca")
    assert_not_nil( sha1(my_string, true) , "sha1 encrypt binary returned nil" )
end

function test_Global_sha256 ()
    assert_equal( sha256(my_string) , "a304c3b35cbb88118dd223a6823b4f10693edd5beab0c1ee2064c70740ae097d", "sha256 of "..my_string.."returned "..sha256(my_string).." Expected : a304c3b35cbb88118dd223a6823b4f10693edd5beab0c1ee2064c70740ae097d" )
    assert_not_nil( sha256(my_string, true) , "sha256 encrypt binary returned nil" )
end

function test_Global_hmac_sha1 ()
	local fail_string = "returned: "..hmac_sha1(secret_key, my_string).." Expected: ee82830a69dad34b581c783f47355a256b454a7e"
    assert_equal( hmac_sha1(secret_key, my_string), "ee82830a69dad34b581c783f47355a256b454a7e", fail_string )
    assert_not_equal ( hmac_sha1(bad_secret_key, my_string) , "ee82830a69dad34b581c783f47355a256b454a7e", "hmac_sha1 encrypt with bad key succeeded" )
    assert_not_nil( hmac_sha1(secret_key, my_string, true) , "hmac_sha1 encrypt binary failed" )
end

function test_Global_hmac_sha256 ()
    assert_equal( hmac_sha256(secret_key, my_string), "443e762ca3594fdb7abf8dcf5bf5703b49a139f4e98664f7e8fc46da90cd0566", "returned: "..hmac_sha256(secret_key, my_string).." Expected: 443e762ca3594fdb7abf8dcf5bf5703b49a139f4e98664f7e8fc46da90cd0566" )
    assert_not_equal ( hmac_sha256(bad_secret_key, my_string) , "443e762ca3594fdb7abf8dcf5bf5703b49a139f4e98664f7e8fc46da90cd0566", "hmac_sha256 encrypt with bad key succeeded" )
    assert_not_nil( hmac_sha256(secret_key, my_string, true) , "hmac_sha256 encrypt binary failed" )
end

function test_Global_base64_encode ()
    assert_equal( base64_encode (my_string) , "VHJpY2twbGF5IHJpenpvY2tzIHRoZSBoaXp6b3VzZS4=", "returned: "..base64_encode (my_string).." Expected:  VHJpY2twbGF5IHJpenpvY2tzIHRoZSBoaXp6b3VzZS4=")
end

function test_Global_base64_decode ()
    assert_equal( base64_decode ("VHJpY2twbGF5IHJpenpvY2tzIHRoZSBoaXp6b3VzZS4=") , my_string, "returned :"..base64_decode ("VHJpY2twbGF5IHJpenpvY2tzIHRoZSBoaXp6b3VzZS4=").." Expected: "..my_string)
end

-- Test Tear down --













