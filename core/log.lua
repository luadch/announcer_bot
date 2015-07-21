--[[

    - written by blastbeat, 20141008

]]--



local logfile, err = io.open( LOG_PATH .. "logfile.txt", "a+" )

assert( logfile, "Fail: " .. tostring( err ) )

local content = logfile:read( "*a" )

local releasefile, err = io.open( LOG_PATH .. "announced.txt", "a+" )

assert( releasefile, "Fail: " .. tostring( err ) )

local releases = { }

for line in releasefile:lines( ) do
  releases[ line ] = true
end

log = { }

log.getreleases = function( )
  return releases
end

log.release = function( buf )
  releases [ buf ] = true
  releasefile:write( buf .. "\n" )
  releasefile:flush( )
end

log.event = function( buf )
  buf = "[" .. os.date( "%y%m%d%H%M%S" ) .. "] " .. buf
  logfile:write( buf .. "\n" )
  logfile:flush( )
  print( buf )
  content = content .. buf
end

function log.find( buf )
  return content:find( buf, 1, true )
end