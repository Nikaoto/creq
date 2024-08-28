-- Sends an https request using a https client loaded from a
-- dynamic library.
--
-- Also queries the steam API and prints the steam user id. Only
-- works with a running steam client with a steam dev acocunt
-- which has the example application "SpaceWar" in its library.
-- Otherwise it will just print an error message from luasteam
-- and crash (which still shows that luasteam was loaded
-- correctly). SpaceWar can be installed by going to
-- 'steam://install/480/' in your browser.

creq = require("creq")

-- All dynamic libraries in the clibs directory will be used by
-- creq depending on the current OS.
luasteam = creq("clibs/luasteam")
https = creq("clibs/https")

-- Use https client
print("https.request(\"https://icanhazip.com\"):")
local code, body, headers = https.request("https://icanhazip.com")
print("https request sent successfully!")
print("code:", code)
print("body:", body)

-- Use dynamically loaded luasteam client (which then loads the
-- steam api, which then also loads other steam libraries).
--
-- In development steam_appid.txt must be in the current working
-- directory, so outside 'example/'. Just Steam's quirk.
--
-- In production, steam_appid.txt must be next to the executable.
--
print("Loading steam...")
local loaded = luasteam.init()
if loaded then
   print("Steam loaded successfully!")
   luasteam.userStats.requestCurrentStats()
   print("Steam ID:", luasteam.user.getSteamID())
end
