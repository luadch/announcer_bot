# Luadch Announcer Bot (without GUI)

## Remarks

- The bot will only work with ADC hubs supporting the OSNR extension
- The bot assumes you have a registered account at the hub
- The bot will only work with SSL secured ADC hubs

## How to use

1. Add your hub credentials and hub address to cfg/hubs.lua
2. Add the directories with new releases to announce to cfg/rules.lua
3. Use openssl and the scripts in certs/ to create a new certificate
4. Start Announcer.exe
