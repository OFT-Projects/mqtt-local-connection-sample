dofile("service.lua")

-- Network Connection Status Log
network_conn_status = tmr.create()
network_conn_status:register(1000, tmr.ALARM_AUTO, function()

	status = wifi.sta.status()
	
	print(string.format("Wireless Network Status: %s", status))
		
	if(status == wifi.STA_IDLE) then print("IDLE")	end
	if(status == wifi.STA_CONNECTING) then print("CONNECTING") end
	if(status == wifi.STA_WRONGPWD)	then print("WRONGPWD") end
	if(status == wifi.STA_APNOTFOUND) then print("APNOTFOUND") end
	if(status == wifi.STA_FAIL) then print("FAIL") end
	if(status == wifi.STA_GOTIP) then print("GOTIP") network_conn_status:stop() end

	print("")

end
)
network_conn_status:start()

wifi.setmode(wifi.STATION)

station_cfg={}
station_cfg.ssid=""
station_cfg.pwd=""
station_cfg.save=false
station_cfg.auto=false
station_cfg.connected_cb=function() print("Connected to wi-fi") end
station_cfg.got_ip_cb=function() service.init("", 8883) end

wifi.sta.config(station_cfg)

wifi.sta.connect()
