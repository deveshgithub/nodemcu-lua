local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close();     
      node.compile(f);
      file.remove(f);   
      file=nil;   
      collectgarbage();
   end
end

local serverFiles = {
   'events.lua',
   'loadfile.lua',
   --'server.lua',
   'util.lua',
   'request.lua',
   'validation.lua',
   'status.lua',
   'config.lua',
   'mqttapp.lua',
   'wificonnection.lua'  
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end
