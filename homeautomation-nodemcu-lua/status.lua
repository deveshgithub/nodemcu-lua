local status =  {};
local validation=require("validation");
local status_topic="/status"


function getstatus(header,reqParamsJson)
  print(" Invoking get status Function");
  --print(" Client "..client);
    
    local str =  "";
        if(validation.isvaliddevicecall(reqParamsJson)) then
              str=cjson.encode(getlatestpinstatus());
              
              local pubtopic = config.mqttconfig.publishtopic..status_topic;
        
              publishmqttmessage(pubtopic,str,0);
        end
        
        print(str);
        collectgarbage();
        
   return str;    
end

function getlatestpinstatus()
    
    local stat_={};
    local statuses = {};
              for pin = 1,9 do
                local pinTab = {};
                pinTab["pinNum"]=pin;
                pinTab["status"]=gpio.read(pin);

                table.insert(statuses,pinTab);   
              end
              stat_["device"]=util.getdevice();
              stat_["statuses"]=statuses;
              stat_["started"]=false;
              stat_["availableMemory"]=""..node.heap();
              stat_["messageId"]=""..rtctime.get();
              
   return stat_;
end


function updatestatus(header,reqParamsJson)
  print(" Invoking update status Function");
  local str = '{"err":"Invalid Device"}';
  ---print(reqParamsJson);
  --if(util.fileExists(STATUS_FILE)) then  
    --Don't use header , as header is from web server
    --from mqtt it will never be received.
    --print(reqParamsJson.action);
     if(validation.isvaliddevicecall(reqParamsJson)) then
            for index,stat in ipairs(reqParamsJson.statuses) 
                do
                        --print(stat.pinNum.." Value:: "..stat.status);
                        --print(stat.status);
                        savedstatus[stat.pinNum]=tonumber(stat.status);                        
                        if stat.status and stat.status>=1 then
                            --print(" setting pin to high "..stat.pinNum..":"..stat.status);
                            gpio.write(stat.pinNum, gpio.HIGH);
                        else
                           -- print(" setting pin to low "..stat.pinNum..":"..stat.status);
                            gpio.write(stat.pinNum, gpio.LOW);
                            
                        end
               end
         
         --assignstatus(savedstatus);
         str = getstatus(header,reqParamsJson);
         --print(" returning content::: "..str);
         
     end

    collectgarbage();   
    return str;  
end

function assignstatus(newstatus)

    for key,value in pairs(newstatus) 
    do          
        
        local localk=tonumber(key);
        
        if localk>=0 and localk<=12 then  
                      
            if value and value>=1 then
                print(" setting pin to high "..localk..":"..value);
                gpio.write(localk, gpio.HIGH);
            else
                print(" setting pin to low "..localk..":"..value);
                gpio.write(localk, gpio.LOW);
                
            end
            
        end
        
    end
    newstatus=nil;
    collectgarbage();
end

function resetstatus(header,reqParamsJson)
  print(" Invoking get status Function");
  --print(" Client "..client);
  if(util.fileExists(STATUS_FILE)) then

    local str = cjson.encode(updateFile(STATUS_FILE,"{}","w+"));

    print(" returning content::: "..str);

    str=nil;
    return "{true}";
  end
  
  return "{false}";
end



return status;

