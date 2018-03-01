package.path = './lib/?.lua;'
package.cpath = './lib/?.so;'

local chuck = require("chuck")
local event_loop = chuck.event_loop.New()
local coroutine = require("ccoroutine")
local redis = require("redis").init(event_loop)


redis.Connect = coroutine.coroutinize1(redis.Connect)

local count = 0

local lastShow = chuck.time.systick()

coroutine.run(function (self)
	local conn = redis.Connect("127.0.0.1",6579)
	if conn then
		local Execute = coroutine.bindcoroutinize2(conn,conn.Execute)
		for i = 1,10 do
			coroutine.run(function ()
				while true do
					local result = Execute("get","hw")
					if not result then
						return
					end
					count = count + 1
					local now = chuck.time.systick()
					local delta = now - lastShow
					if delta >= 1000 then
						lastShow = now
						print(string.format("count:%.0f/s",count*1000/delta))
						count = 0
					end
				end
			end)
		end
	end
end)


event_loop:WatchSignal(chuck.signal.SIGINT,function()
	event_loop:Stop()
	print("stop")
end)

event_loop:Run()

