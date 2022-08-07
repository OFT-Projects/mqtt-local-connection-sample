default_client_id = 0

keepalive = 30

log_header = "LOG:"
on_connect_log = "Module has connected to broker"
on_connect_fail_log = "Module has failed to connect"
on_puback_log = "Module has just became a publisher"
on_suback_log = "Module has just became a subscriber"
on_unsuback_log = "Module has just unsubscribed"
on_offline_log = "Module and its connection to broker has just gone offline"

service = { mqtt_client, hostname, port }

function on_connect_fail_cb (client, reason) print(string.format("%s %s: %s", log_header, on_connect_fail_log, reason)) end
function on_puback_cb (client) print(string.format("%s %s", log_header, on_puback_log)) end
function on_suback_cb (client) print(string.format("%s %s", log_header, on_suback_log)) end
function on_unsuback_cb (client) print(string.format("%s %s", log_header, on_unsuback_log)) end
function on_offline_cb (client) print(string.format("%s %s", log_header, on_offline_log)) end

service.init = function (hostname, port)

	service.mqtt_client = mqtt.Client(default_client_id, keepalive)
	service.hostname = hostname
	service.port = port

	service.mqtt_client:on("connfail", on_connect_fail_cb)
	service.mqtt_client:on("puback", on_puback_cb)
	service.mqtt_client:on("suback", on_suback_cb)
	service.mqtt_client:on("unsuback", on_unsuback_cb)
	service.mqtt_client:on("offline", on_offline_cb)
	
	service.mqtt_client:on("message", function(client, topic, data)
		print(topic .. ":")
		if(topic == "led") then
			if data ~= nil then	
				if data == "1" then
					gpio.write(1, gpio.HIGH)
				else
					gpio.write(1, gpio.LOW)
				end
				print(data)
			end
		end
		if(topic == "pump") then
			if data ~= nil then
				if data == "1" then
					gpio.write(2, gpio.HIGH)
				else
					gpio.write(2, gpio.LOW)
				end
				print(data)
			end
		end
	end)
	
	print("Trying to connect to broker...")
	service.mqtt_client:connect(hostname, port, false, function(client) 
		print("Connected to mqtt")
		print(string.format("%s %s %s %s", log_header, on_connect_log, service.hostname, service.port))

		
		client:subscribe({["led"]=0, ["pump"]=0},  function(client) print("\nSubscribed to LDR and PUMP\n") end)
		
		tmr.create():alarm(500, tmr.ALARM_AUTO, function() 
			data = adc.read(0)
			str = string.format("LDR: %s", data)
			client:publish("ldr", str, 0, 0, function() print(string.format("Data sent: %s", str)) end)
		end)
		

		gpio.mode(1, gpio.OUTPUT)
		gpio.mode(2, gpio.OUTPUT)
		gpio.write(1, gpio.LOW)
		gpio.write(2, gpio.LOW)
	end)
end



