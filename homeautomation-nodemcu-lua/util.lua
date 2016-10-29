
module("util", package.seeall)
--local status = require 'status';
local counter=1;

local charset = {}
    
-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function contains(String,Start)
   local hasstring=false;
   local indx=nil;
   
   if(String) then
    indx=string.find(String,"%"..Start.."*",0,false);
   end
   
   if(indx) then
     
    hasstring = true;
    
   end
   return hasstring;
end

function starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function split(str,sep)
  local array = {}
  local reg = string.format("([^%s]+)",sep)
  for mem in string.gmatch(str,reg) do
    table.insert(array, mem)
  end
  return array
end

function fileExists(fileName)
   if not file.exists(fileName) then
        print("Looks like file is not present.",fileName);
        return false;
    end
    return true;
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function invoke(functionName,header,params)
    local args   = split(functionName, ".") ; -- Split the function name to get the module
    local module = table.remove(args, 1);   -- Get the module ex: xx.yy then this would return xx 
    
    if module  then        
    
        require(module); -- make the module as required .
        
        local command = table.remove(args, 1);      -- get the name of the method that needs to be invoked .
        
        if command then                        
        
            local resp = _G[command](header,params);
            
            return resp;
        end
    end
end

function getmoduleandaction(req)
    local arr = split(req,"/");
    return arr[1],arr[2];
end


function getdevice()
  local device = {};
  device["hostname"]=config.wifi.hostname;
  return device;
end

local function random(length)
      counter = counter + 1;
      math.randomseed(counter);
      --math.randomseed(math.random()+100);
      --print(math.random());
    
      if length > 0 then
        return random(length - 1) .. charset[math.random(1, #charset)]
      else
        return ""
      end      
end

function getencrypted(data)
    local cipher = crypto.encrypt("AES-ECB", config.system.enckey, data);  
    local strB64=encoder.toBase64(cipher);
    return strB64;
end

function getdecrypted(data)
   -- print(" Before decrypting the data"..data);
    local decrypted = crypto.decrypt("AES-ECB", config.system.enckey, encoder.fromBase64(data));
    --print(decrypted);
    return decrypted;
end
