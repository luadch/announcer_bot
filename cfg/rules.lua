-- your announcing rules
-- this file can be changed during runtime

rules = { }

local command = "+addrel %C %R"        -- command to announce; %C is the given category, %R the release name

local pwd = lfs.currentdir( )		      -- replace this by your root directory

local APPZ = pwd .. "/example/APPZ"	  -- directories to announce; use absolute path names here
local MP3 = pwd .. "/example/MP3"

rules[ APPZ ] = { }			              -- new rules for directory "APPZ" to announce
rules[ APPZ ].active = false          -- rule is active
rules[ APPZ ].category = "Software"	  -- release category; will be used as %C in addrel command
rules[ APPZ ].blacklist = {		        -- patterns in release/folder names, which will block the release (no effect, if table empty)
				
  [ "(incomplete)" ] = true,
  [ "(nuked)" ] = true,
  [ "(no-sfv)" ] = true,
  [ "[incomplete]" ] = true,
  [ "[nuked]" ] = true,
  [ "[no-sfv]" ] = true,

}
rules[ APPZ ].whitelist = {		        -- patterns in release/folder names, which will be required to announce release (no effect, if table empty)
					
  photoshop = true,
  --app = true,
  ["-TVP"] = true,

}
rules[ APPZ ].command = command	      -- use default command

rules[ MP3 ] = { }
rules[ MP3 ].active = true
rules[ MP3 ].daydirscheme = true	    -- day dir scheme; assumes folders in the form "example/MP3/<mmdd> which will be announced (rekursive mode);
rules[ MP3 ].zeroday = true		        -- announces only today
rules[ MP3 ].category = "MP3"
rules[ MP3 ].blacklist = {

  [ "(incomplete)" ] = true,
  [ "(nuked)" ] = true,
  [ "(no-sfv)" ] = true, 
  [ "[incomplete]" ] = true,
  [ "[nuked]" ] = true,
  [ "[no-sfv]" ] = true,

}
rules[ MP3 ].whitelist = {
  
}
rules[ MP3 ].command = command
