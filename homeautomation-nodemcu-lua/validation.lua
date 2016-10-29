--All the validations should go under this module
--Inlcuding authencitation, mac address , session, resource access, method , protocol etc..
module("validation", package.seeall);


function validate(header) 
    local isvalid = false;
    
    if(header and header["route_config"]) then
    
        local route_config=header["route_config"];
        
        local contenttype = header["Content-Type"];
                
        local req_contentype=route_config.req_contentype;

        local contenttypeidx=string.find(contenttype,req_contentype,0,true);
         
         print(contenttypeidx);
         
        if(contenttype and contenttypeidx and contenttypeidx>0) then

            isvalid=true;
            
        end

        if(isvalid and validateaction(header)) then
            
            isvalid=true;

        end

        if(isvalid and validatecontentlength(header)) then
          
            isvalid=true;

        end
    end

    return isvalid;
    
end

function validateaction(header)
  
  print("validating action");
  
  local module = header.module;
  
  local action = module[header.action];
  
  if(action and header.route_config.routeto) then
  
     return true;
     
  end
  
  return false;
end


function validatecontentlength(header)

  print(" validateContentLength ");
  
  local route_config=header["route_config"];
   
  local inputContentLength = header["Content-Length"];
  
  local validLength = header.route_config.req_mincontentlen;
  
  if not validLength then

        validLength=0;
        
  end

  if tonumber(validLength) <= tonumber(inputContentLength) then
   
    return true;
  
  else
  
    print("Content is NOt VAlid returning FALSE");
    
    return false;
  
  end

end

function issecured(action,header)
  local secured = routeconfig[action].secured;
  print(action.." is secured :: "..secured);
  local secured = false;
  --If the action is marked as secured then
  --the light weight secure key should be present
  if secured  then

    if(header.lwsk) then

      secured=true;

    else

      secured=false;

    end

  else

    secured=true;

  end

  return secured;
end


function isvaliddevicecall(jsonpayload)
  
  local valid = false;  
  pcall(function () 
  if (jsonpayload.device.hostname) then
        if(jsonpayload.device.hostname==config.wifi.hostname) then
                    valid = true;
        end
   end  
  end);
  return valid;
end
