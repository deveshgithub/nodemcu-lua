tmr.delay(1000000);

print(" Server - Heap B4... "..node.heap());







--print("Host Name for this chip is... ",config.wifi.hostname);

--local cipher = crypto.encrypt("AES-ECB", config.system.enckey, "Hi, I'm secret!");

--print(crypto.toHex(crypto.hash("sha1","abc")))

--print(cipher);

--print(crypto.toHex(cipher));

--print(crypto.decrypt("AES-ECB", config.system.enckey, cipher))

--local encryptedText=crypto.encrypt("AES-ECB", "1234567890abcdef", "Hi, I'm secret!");
--print(encryptedText);
--local decryptedText=crypto.decrypt("AES-ECB", "1234567890abcdef", encryptedText);
--print(encryptedText);
--local cipher = crypto.decrypt("AES-ECB", "esp0001", "test me");
--print(cipher);
--print(crypto.decrypt("AES-ECB", "esp0001", "DB822708D11271D3F2CDD63D7333E793E31372C3BE226B49241F6701CA455026F57016A4EF188665A8214AC7DAD2BEEEF06485C5C68FC03A4597EBB3F87176353EE629BC04B7BBD7AD0EEDF13A2535C4A0EB945E9481259420421CB63B5B0D7145E57940912CE561A9AA2503EE52BFF4269F359B9D25EC80B60BC163D06DA94226877037FCBC89BE6F4DF3E16FF073F9EAC536EF46CFB00CD6012F7798986518"));

srv=net.createServer(net.TCP,10);


srv:listen(80,function(conn)
  conn:on("receive", function(client,payload) 
    print("Received Request !!! ");
    print(" Heap Before Processing... "..node.heap());
    
    if payload:find("Content%-Length:") or bBodyMissing then
      if fullPayload then fullPayload = fullPayload .. payload else fullPayload = payload end
      if (tonumber(string.match(fullPayload, "%d+", fullPayload:find("Content%-Length:")+16)) > #fullPayload:sub(fullPayload:find("\r\n\r\n", 1, true)+4, #fullPayload)) then
        bBodyMissing = true
        return
      else
        --print("HTTP packet assembled! size: "..#fullPayload)        
        payload = fullPayload
        fullPayload, bBodyMissing = nil
      end
    end
    print(payload);
    local resp = "";

    pcall(function()

        resp = processHttpRequest(payload);
    
        if(resp==nil) then
    
          resp = "{}";
    
        end

    end);

    local temp =   "HTTP/1.1 200 OK\r\nServer: "..config.wifi.hostname.."\r\nContent-Type: application/json\r\n\r\n"

    local response = temp..resp.."\n";

    print(" response ::=> "..response);
    
    client:send(response);  
   

  end)

  conn:on("sent", function(client) 
        client:close();
        client = nil;
    
        payload=nil;
    
        collectgarbage();

        print(" Heap After Processing... "..node.heap());
  end)
end)

function processHttpRequest(payload)
   local request=require("request");

   header = request.parseRequest(payload);


  if(header==false) then

    return "{'err':'Invalid Content'}";
  end

  --print(" Method :: "..header.method);

  --print(" Action :: "..header.action);



  local reqParamsJson ={};

  if pcall(function () reqParamsJson=cjson.decode(header.params); end) then

  end

  -- Get the function that needs to be invoked for given action received.

  local functionToInvoke=header.route_config.routeto;

  if(functionToInvoke==nil) then

    return false;

  end

  --print(" functionToInvoke "..functionToInvoke);

  --local resp = _G[functionToInvoke](header,reqParamsJson); -- calls foo from the global namespace
  local resp = util.invoke(functionToInvoke,header,reqParamsJson);
  
  reqParamsJson=nil;header=nil;functionToInvoke=nil;payload=nil;
  
  request=nil;
  
  return resp; 

end


 
collectgarbage();
print(" Server - Heap After... "..node.heap());

