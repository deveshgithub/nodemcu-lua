wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T) 
 print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 end)
 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T) 
 print("\n\tIP:"..T.IP.."\n\tnetmask:"..T.netmask.."\n\tgateway:"..T.gateway);
 --mdns.register(config.hostname, { description=config.hostname, service="http", port=80, location=config.hostname});
 --net.multicastJoin(T.IP, "224.0.0.251");
 end)
 
