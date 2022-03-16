-- misc configuration

cfg = { }

cfg.botdesc = "blastbeats announcer bot"          -- your bot description
cfg.botshare = 1073741824                         -- your bot share in bytes (to bypass min share size)
cfg.botslots = 2                                  -- your bot slots (to bypass min slot size)
cfg.announceinterval = 300                        -- announce new releases every 300 seconds
cfg.sockettimeout = 60                            -- sockets are blocking for 60 seconds
cfg.sleeptime = 10                                -- waiting 10 seconds before reconnect to server or starting announcing

cfg.sslparams = {  

    mode = "client",
    key = CERT_PATH .. "serverkey.pem",
    certificate = CERT_PATH .. "servercert.pem",

    --// use this config for:  TLSv1.3 with AES256 + CHACHA20 + AES128 (default); requires OpenSSL 1.1.1 or higher
    protocol = "tlsv1_3",
    ciphers = "HIGH",
    ciphersuites = "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"

}
