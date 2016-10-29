tmr.delay(100000);
local util=require("util");
local validation=require("validation");
local status=require("status");
rtctime.set(1477515651, 0);
print(" Init - Heap B 4... "..node.heap());

for pin=1,9 do
    --print("Pin "..pin);
    gpio.mode(pin, gpio.OUTPUT);
        
end

dofile("compiledelete.lua");
dofile("loadfile.lc");
dofile("wificonnection.lc");
dofile("events.lc");
require("mqttapp");
 
if (config.system.server) then
dofile("server.lua");
else
print(" @@@@@ SERVER DISABLED $$$$$$$$$$$$$$$$$$$$$$$$$$");
end

    if pcall(function () 
         
          mqtt_start(); 
        end) then
    
      print("MQTT Sucessfully Started !!!");
      --trig(pin, "down", pin1cb)    
      --mqtt:publish(topic, payload, qos, retain[, function(client)])
        
    else
    
      print("@@@@@@@@@@@@ MQTT Startup Failed @@@@@@@@@@@");
    
    end
    
package.loaded['compiledelete.lua']=nil;
-- package.loaded['server.lc']=nil;
collectgarbage();
print(" Init - Heap After... "..node.heap());

if(savedstatus) then
     assignstatus(savedstatus);
     savedstatus={};
end
