
function XRE( )

    local xre =
        
        {
            socket = Socket(),
            
            input_buffer = "",
            
            app_name = "",
            
            event_index = 0,
        
        }
    
    ---------------------------------------------------------------------------
    -- Socket callbacks
    ---------------------------------------------------------------------------
    
    function xre.socket.on_connected( socket )

        -- Send the onConnect event    
        
        local event =
        {
            name = "onConnect",
            params =
            {
                deviceId = "",
                deviceCaps =
                {
                    receiverVersion = "0.0.1",
                    platform = "Linux",
                    mimeTypes =
                    {
                        "image/jpeg",
                        "image/jpg",
                        "image/png",
                        "image/gif",
                        "video/flv",
                        "video/f4v",
                        "video/mp4",
                        "video/mov",
                        "video/mp4v",
                        "application/x-shockwave-flash"
                    },
                    nativeDimensions =
                    {
                        screen.w,
                        screen.h
                    },
                    platformVersion = "4.6.3",
                    receiverType = "Native"
                },
                appParams =
                {
                    PHPSESSID = "undefined"
                },
                applicationName = xre.app_name,
                reconnect = false,
                minimumVersion = "0",
                currentCommandIndex = 0,
                authenticationToken = json.null
            }
        }
    
        xre:send_event( event , true )
        
    end
    
    ---------------------------------------------------------------------------

    function xre.socket.on_disconnected( socket )
    
        pcall( xre.on_disconnected , xre )
    
    end
    
    ---------------------------------------------------------------------------

    function xre.socket.on_connect_failed( socket )
    
        print( "CONNECT FAILED" )
    
    end
    
    ---------------------------------------------------------------------------

    function xre.socket.on_read_failed( socket )
    
        socket:disconnect()
        
    end
    
    ---------------------------------------------------------------------------

    function xre.socket.on_write_failed( socket )
    
        socket:diconnect()
    
    end
    
    ---------------------------------------------------------------------------

    function xre.socket.on_data_read( socket , data )
        
        -- We append the data to the input buffer, then we wait until we have
        -- 4 bytes. Once we have 4 bytes, we can determine the length of the
        -- next message - and we wait until we've received it all. Then, we
        -- invoke on_command for each message.
        
        xre.input_buffer = xre.input_buffer..data
        
        while # xre.input_buffer >= 4 do
        
            local message_length = uint32_from_be( xre.input_buffer )
            
            if # xre.input_buffer < message_length + 4 then
                
                break
            
            end
            
            local json_command = string.sub( xre.input_buffer, 5, 4 + message_length )
            
            xre.input_buffer = string.sub( xre.input_buffer , 5 + message_length )
            
            local command = json:parse( json_command )
            
            if not command then
            
                print( "FAILED TO PARSE COMMAND '"..json_command.."'" )
            
            else
            
                pcall( xre.on_command , xre , command )
                
            end
                    
        end
        
    end
    
    ---------------------------------------------------------------------------
    -- Methods of XRE
    ---------------------------------------------------------------------------

    function xre.send_event( xre, event , send_header )
    
        event.timestamp = os.time()
        
        event.eventIndex = xre.event_index
        
        xre.event_index = xre.event_index + 1
        
        
        local output = ""
        
        if send_header then
        
            output = "XRE\r\n"
        
        end
        
        local json_event = json:stringify( event )

        xre.socket:write( output..uint32_to_be( # json_event )..json_event )
    
    end
        
    ---------------------------------------------------------------------------
    
    function xre.connect( xre , host_and_port , app_name )
    
        xre.input_buffer = ""
        
        xre.app_name = app_name
        
        xre.event_index = 0
        
        xre.socket:connect( host_and_port , 80 )
    
    end

    ---------------------------------------------------------------------------

    function xre.disconnect( xre )
    
        xre.socket:disconnect()
    
    end
    
    ---------------------------------------------------------------------------

    return xre
    
end
