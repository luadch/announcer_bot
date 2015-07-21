-- misc configuration

cfg = { }

cfg.botdesc = "blastbeats announcer bot"          -- your bot description
cfg.botshare = 1073741824                          -- your bot share in bytes (to bypass min share size)
cfg.botslots = 2                                  -- your bot slots (to bypass min slot size)
cfg.announceinterval = 300                        -- announce new releases every 300 seconds
cfg.sockettimeout = 60                            -- sockets are blocking for 60 seconds
cfg.sleeptime = 10                                -- waiting 10 seconds before reconnect to server or starting announcing

cfg.sslparams = {  

    mode = "client",
    key = CERT_PATH .. "serverkey.pem",
    certificate = CERT_PATH .. "servercert.pem",

    --// use this config for: TLSv1
    protocol = "tlsv1",
    ciphers = "ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:AES256-SHA:ECDHE-RSA-AES128-SHA",

    --// use this config for: TLSv1.2
    --protocol = "tlsv1_2",
    --ciphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:AES256-SHA:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256",

}
