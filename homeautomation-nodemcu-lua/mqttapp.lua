local mqttapp = {}  

m = nil
local enableflag=config.system.mqtt;

local status_pub_topic="myhome/fromhome/status";
local startup_pub_topic="myhome/fromhome/started";

-- Sends a simple ping to the broker
local function send_ping()  
    if enableflag then
        m:publish(config.mqttconfig.publishtopic .. "ping","id=" .. config.mqttconfig.clientid,0,0)
    end
    collectgarbage();
end

-- Sends my id to the broker for registration
local function register_myself()  
    if enableflag then
        m:subscribe(config.mqttconfig.subscribetopic,2,function(conn)
            print("Successfully subscribed to data endpoint :: "..config.mqttconfig.subscribetopic)
        end)
    end
    collectgarbage();
end

function mqtt_start()      
        if(enableflag) then
                print(" MQTT is STARTING!!!!!!");
                m = mqtt.Client(config.mqttconfig.clientid, 86400,"","");
                -- register message callback beforehand
                m:on("message", function(conn, topic, data)     
                  collectgarbage();            
                  if data ~= nil then
                        --print(topic .. ": " .. data);       
                    
                        
                        delegatecall(data);--updatestatus('{"params":""}',);
                        data=nil;
                     
                  end
                end);
                -- Connect to broker
                --host,port,secure_flag,autoreconnect flag,
                m:connect(config.mqttconfig.host, config.mqttconfig.port, 0, 1,function(client) 
                    register_myself();    
                    --tmr.stop(6);
                   --tmr.alarm(6, 10000, 1, send_ping);
                    send_mqtt_startup_message();
                    end);
         else 
                print("@@@@@@ MQTT IS DISABLED !!!!!!! FOR THIS DEVICE !!!!! @@@@@@ ");            
         end
         collectgarbage();
end

function publishmqttmessage(topic,data,retainflg)
    print(" Init - Heap B 4.MQTT_sendmessage.. "..node.heap());
    if (retainflg==nil)  then
        retainflg = 0;
    end
    if enableflag then
        local cipher = data;
        
        if(config.system.sendencrypted) then
    
            cipher = util.getencrypted(data);
            --topic = topic.."_"..config.wifi.hostname;
            --cipher = encoder.toHex(cipher);
        end
        print(" Init - Heap B 4 _sendmessage publish call.. "..node.heap());
        m:publish(topic,cipher,2,retainflg,function(client) print("Message delivered at "..topic);end );
        print(" Init - Heap AFTER _sendmessage publish call.. "..node.heap());
        collectgarbage();
    end
    print(" Init - Heap AFTER MQTT_sendmessage.. "..node.heap());
end
function send_mqtt_message(data)
    print(" Init - Heap B 4.MQTT send_mqtt_message.. "..node.heap());
    if enableflag then
        print("Sending message to broker!!!!");    
        publishmqttmessage(status_pub_topic,data,o);
    end
    collectgarbage();
    print(" Init - Heap AFTER MQTT send_mqtt_message.. "..node.heap());
end

function send_mqtt_startup_message()
    print(" Init - Heap B 4.MQTT send_mqtt_startup_message.. "..node.heap());
    if enableflag then
        print("Sending Startup message to broker!!!!");    
        local stat_=getlatestpinstatus();  
        stat_["started"]=true;
        local data=cjson.encode(stat_);
        publishmqttmessage(status_pub_topic,data,1);
    --m:publish(startup_pub_topic,str,2,1,function(client) print("Message delivered at "..startup_pub_topic);end );
    end
    collectgarbage();
    print(" Init - Heap AFTER .MQTT send_mqtt_startup_message.. "..node.heap());
end

function delegatecall(data)
    print(" Init - Heap B 4.MQTT delegatecall.. "..node.heap());
    if enableflag then
        if(config.system.receiveencrypted)  then
            print("Communicaton is encrypted, calling for decryption");
            data = util.getdecrypted(data);
        end
        
        data = cjson.decode(data)
        
        if(data and data.action) then  
    
            local module,action = util.getmoduleandaction(data.action);
            module = routeconfig[module];
            
              if (module==nil) then
            
                return false;
            
              end
            
            
              action = module[action];
    
              local functionToInvoke=action.routeto;
    
              if(functionToInvoke==nil) then
    
                return false;
            
              end
    
              local resp = util.invoke(functionToInvoke,{},data);
           
        end
    end
    collectgarbage();   
    print(" Init - Heap AFTER .MQTT delegatecall.. "..node.heap());     
end


return mqttapp
