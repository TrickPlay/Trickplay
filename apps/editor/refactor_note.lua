- header.lua 
	--BUTTON_UP         = 0
	--BUTTON_DOWN       = 0
	--mouse_state       = BUTTON_UP
	--main.lua 관련 코드 삭제 

	-- Section index constants. These also determine their order.
	--SECTION_FILE      = 1
	--SECTION_EDIT      = 2
	--SECTION_ARRANGE   = 3
	--SECTION_SETTING   = 4
	--BUTTON_TEXT_STYLE
	--Cursor Images 
	-- 
	ui = {factory, ui_element, editor_lib}

-. 기존의 파일 구조는 유지하되 새로운 파일로 분리가 필요하면 그렇게 하자. 
-. 글로벌 함수 변수를 가급적 로컬로 변환한다.h 
	-. 예를 들자면 header = dofile (header.lua)
	-. 불가피한 글로벌 변수 혹은 함수는 header의 글로벌 섹션에 모아 관리하자 

-. 불필요한 코드를 삭제하자
-. indentation 

ui =
    {
        assets              = assets,
        factory             = factory,
		ui_element			= ui_element, 
		editor_lib 			= editor_lib,
    }

1,$s/S_SELECT/hdr.S_SELECT/g          
1,$s/S_RECTANGLE/hdr.S_RECTANGLE      
1,$s/S_POPUP/hdr.S_POPUP        	
1,$s/S_MENU/hdr.S_MENU        
1,$s/S_FOCUS/hdr.S_FOCUS      
1,$s/S_MENU_M/hdr.S_MENU_M	
1,$s/ADD/hdr.ADD        
1,$s/CHG/hdr.CHG       
1,$s/DEL/hdr.DEL      
1,$s/ARG/hdr.ARG		
1,$s/BRING_FR/hdr.BRING_FR
1,$s/SEND_BK/hdr.SEND_BK		   
1,$s/BRING_FW/hdr.BRING_FW	  
1,$s/SEND_BW/hdr.SEND_BW		 
1,$s/DEFAULT_COLOR/hdr.DEFAULT_COLOR
1,$s/current_dir/hdr.current_dir 
1,$s/current_inspector/hdr.current_inspector 
1,$s/current_fn/hdr.current_fn  	 
1,$s/current_focus/hdr.current_focus 	
1,$s/input_mode/hdr.input_mode     
1,$s/dragging/hdr.dragging      
1,$s/menu_hide/hdr.menu_hide    
1,$s/contents/hdr.contents   
1,$s/item_num/hdr.item_num 	   
1,$s/guideline_show/hdr.guideline_show	
1,$s/h_guideline/hdr.h_guideline   
1,$s/v_guideline/hdr.v_guideline  
1,$s/focus_type/hdr.focus_type  
1,$s/selected_objs/hdr.selected_objs	
1,$s/undo_list/hdr.undo_list 	  
1,$s/redo_list/hdr.redo_list 	 
1,$s/BG_IMAGE/hdr.BG_IMAGE 
1,$s/BG_IMAGE_40/hdr.BG_IMAGE_40 
1,$s/BG_IMAGE_80/hdr.BG_IMAGE_80 
1,$s/BG_IMAGE_white/hdr.BG_IMAGE_white 
1,$s/BG_IMAGE_import/hdr.BG_IMAGE_import 
1,$s/inspecotr_skins/hdr.inspector_skins 
