--[[

    - written by blastbeat, 20141008

]]--


local ssl = require "ssl"
local socket = require "socket"

local basexx = require "basexx"

local sslctx, err = ssl.newcontext( cfg.sslparams )

assert( sslctx, "Fail: " .. tostring( err ) )

net = { }

net.loop = function( )
  local client, err = socket.tcp( )
  assert( client, "Fail: " .. tostring( err ) )
  log.event( "Try to connect to hub '" .. hub.name .. "' via " .. hub.nick .. "@" .. hub.addr .. ":" .. hub.port .. " with timeout " .. cfg.sockettimeout .. " seconds..." )
  client:settimeout( cfg.sockettimeout )
  repeat
    local succ, err = client:connect( hub.addr, hub.port )
    if err then
      log.event( "Fail: " .. tostring( err ) )
      log.event( "Try to reconnect in " .. tonumber( cfg.sleeptime ) or 10 .. " seconds..." )
      socket.sleep( tonumber( cfg.sleeptime ) or 10 )
    end
  until succ
  log.event( "Connected. Try a SSL handshake..." )
  local client, err = ssl.wrap( client, sslctx )
  assert( client, "Fail: " .. tostring( err ) )
  client:settimeout( cfg.sockettimeout )
  local succ, err = client:dohandshake( )
  if err then
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  local cert = client:getpeercertificate( )
  log.event( "Generate keyprint..." )
  local fingerprint = basexx.to_base32( basexx.from_hex( cert:digest( "sha256" ) ) ):gsub( "=", "" ) 
  if fingerprint ~= hub.keyp then
    log.event( "Keyprint mismatch, closing..." )
    client:close( )
    return true
  end
  log.event( "Connection established. Try now to login..." )
  log.event( "Sending support..." )
  local succ, err = client:send( "HSUP ADBASE ADTIGR ADOSNR ADKEYP ADADCS ADADC0\n" )
  if err then
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  log.event( "Waiting for hub support..." )
  local buf, err = client:receive( "*l" )
  if err then 
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  if not buf:find( "ADOSNR" ) then
    log.event( "Fail: No OSNR support, closing..." )
    client:close( )
    return true
  end
  log.event( "Hub has OSNR support, waiting for SID..." )
  local buf, err = client:receive( "*l" )
  if err then 
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  local sid
  if buf:find( "ISID" ) then
    sid = buf:sub( 6, 9 )
    log.event( "Provided SID: " .. sid )
  else
    log.event( "No SID provided, closing..." )
    client:close( )
    return true
  end
  log.event( "Waiting for hub INF..." )
  local buf, err = client:receive( "*l" )
  if err then 
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  if not buf:find( "IINF" ) then
    log.event( "No INF provided, closing..." )
    client:close( )
    return true
  else
    log.event( "Hub INF provided, try to send own INF..." )
    local succ, err = client:send( "BINF " .. sid .. " VErelspam++ NI" .. adclib.escape( tostring( hub.nick ) ) .. " PD" .. id.pid .. " ID" .. id.cid .. " HN0 HR0 HO0 SUOSNR,ADC0,ADCS SS" .. cfg.botshare .. " SL" .. cfg.botslots .. " DE" .. adclib.escape( tostring( cfg.botdesc ) ) .. "\n" )
    if err then
      log.event( "Fail: " .. tostring( err ) )
      return false
    end
  end
  log.event( "Own INF sended, waiting for password request..." )
  local buf, err = client:receive( "*l" )
  if err then 
    log.event( "Fail: " .. tostring( err ) )
    return false
  end
  local salt
  if not buf:find( "GPA" ) then
    log.event( "No password request, closing..." )
    client:close( )
    return true
  else
    salt = buf:sub( 6, -1 ):match( "^([A-Z2-7]+)" )
  end
  log.event( "Salt provided, try to send password..." )
  local pas = adclib.hashpas( hub.pass, salt )
  local succ, err = client:send( "HPAS " .. pas .. "\n" )
  if err then
    log.event( "Fail: " .. tostring( err ) )
    client:close( )
    return false
  end
  log.event( "Waiting for login..." )
  local buf, err = client:receive( "*l" )
  if err then 
    log.event( "Fail: " .. tostring( err ) )
    return false
  end  
  if not buf:find( "BINF" ) then
    log.event( "Login failed. Last hub message: " .. buf )
    client:close( )
    return true
  end
  local hubcount = "HR1"
  if buf:find( "CT8" ) then
    hubcount = "HO1"
  end
  --local succ, err = client:send( "BINF " .. sid .. " VErelspam++ NI" .. adclib.escape( tostring( hub.nick ) ) ..  " " .. hubcount .. " SUOSNR SS" .. cfg.botshare .. " SL" .. cfg.botslots .. " DE" .. adclib.escape( tostring( cfg.botdesc ) ) .. "\n" )
  local succ, err = client:send( "BINF " .. sid .. " " .. hubcount .. "\n" )
  if err then
    log.event( "Fail: " .. tostring( err ) )
    client:close( )
    return false
  end  
  log.event( "Login complete." )
  log.event( "Waiting " .. ( tonumber( cfg.sleeptime ) or 10 ) .. " seconds before starting the announcer..." )
  socket.sleep( tonumber( cfg.sleeptime ) or 10 )
  while true do
    local found = announce.update( )
    for release, cfg in pairs( found ) do
      local command = cfg.command
      local category = cfg.category
      if ( type( category ) ~= "string" ) or ( type( command ) ~= "string" ) then
        log.event( "Your rules.lua is broken. No valid category/command given for release '" .. release .. "' given." )
      else
        command = command:gsub( "%%C", cfg.category )
        command = command:gsub( "%%R", release )
        command = adclib.escape( command )
        local succ, err = client:send( "BMSG " .. sid .. " " .. command .. "\n" )
        if err then 
          log.event( "Fail: " .. tostring( err ) )
          return false
        else
          log.release( release )
          log.event( "Announced '" .. release .. "'.")
        end
      end
    end
    socket.sleep( tonumber( cfg.announceinterval ) or 5 * 60 ) 
    local succ, err = client:send( "BINF " .. sid .. " VErelspam++\n" ) -- send some keeping alive ping
    if err then log.event( "Fail: " .. tostring( err ) ) return false end
  end   
end

log.event( "Starting bot..." )
repeat
until net.loop( )
log.event( "Bot terminated." )
os.exit( )