--[[

    - written by blastbeat, 20141008

]]--

local lfs = require "lfs"

local alreadysent = log.getreleases( )

local match = function( buf, patternlist, white )
  buf = buf:lower()
  local count = 0
  for pattern, _ in pairs( patternlist ) do
    pattern = pattern:lower( )
    count = count + 1
    if buf:find( pattern, 1, true ) then return true end
  end
  if white and ( count == 0 ) then return true end
  return false
end

local search = function( path, cfg, found )
  for release in lfs.dir( path ) do
    if ( release ~= "." ) and ( release ~= "..") and ( not announce.blocked[ release ] ) and ( not alreadysent[ release ] ) then
      if match( release, cfg.blacklist ) or ( not match( release, cfg.whitelist, true ) ) then
        log.event( "Release '" .. release .. "' blocked." )
        --announce.blocked[ release ] = true
      else
        found[ release ] = cfg
      end
    end
  end
end

announce = { }
announce.blocked = { }

announce.update = function( )
  local file, err = loadfile( CFG_PATH .. "rules.lua" )
  if not err then
    file( )
  else
    log.event( "Your rules.lua is broken: " .. err .. "; Using old configuration." )
  end
  local found = { }
  log.event( "Search directories for updates..." )
  for path, cfg in pairs( rules ) do
    if cfg.active then
      path = tostring( path )
      local mode, err = lfs.attributes( path, "mode" )
      if mode ~= "directory" then
        log.event( "Warning: directory '" .. path .. "' is not a directory or does not exist, skipping..." )
      elseif ( ( type( cfg.blacklist ) ~= "table" ) or type( cfg.whitelist ) ~= "table" ) then
        log.event( "Warning: config for '" .. path .. "' is broken, skipping..." )
      else
        log.event( "Searching in '" .. path .. "'..." )
        if cfg.daydirscheme then
          if cfg.zeroday then
            local today = path .. "/" .. os.date( "%m%d" )
            local mode = lfs.attributes( today, "mode" )
            if mode ~= "directory" then
              log.event( "Warning: directory '" .. today .. "' seems not to exist, skipping..." )
            else
              search( today, cfg, found )
            end
          else
            for dir in lfs.dir( path ) do
              if ( dir ~= "." ) and ( dir ~= "..") then
                local n = tonumber( dir )
                if n and ( 0101 <= n ) and ( 1231 >= n ) then  -- rough estimate; 1199 is still allowed, though
                  search( path .. "/" .. dir, cfg, found )
                else
                  log.event( "Warning: directory '" .. dir .. "' fits not in 4 digit day dir scheme, skipping..." )
                end
              end
            end
          end 
        else
          search( path, cfg, found )           
        end
      end
    end
  end
  local c = 0
  for i, k in pairs( found ) do c = c + 1 end
  log.event( "...finished. Found " .. c .. " new releases." )
  return found
end