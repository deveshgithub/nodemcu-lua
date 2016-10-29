local config =  {};


function getconfig(header,reqParamsJson)
  print(" Invoking getconfig Function");

  local str = cjson.encode(getDataFromFile(header.route_config.file));

  return str;
end


function update(header,reqParamsJson)
  print(" Invoking updateconfig Function");
  print(" updateconfig header "..header.Host);
  print(" Invoking get status Function");
  --print(" Client "..client);
  if(util.fileExists(header.route_config.file)) then

    local currentstatus = getDataFromFile(header.route_config.file);

    print(" Header Params ..... "..header["params"]);
    print(" Header Params ..... "..type(header["params"]));


    for key,value in pairs(reqParamsJson)
    do
      currentstatus[key]=value;
    end


    local str = cjson.encode(updateFile(header.route_config.file,cjson.encode(currentstatus),"w+"));

    print(" returning content::: "..str);
    return str;
  end
  print(" header "..header.Host);

end

function upload(header,reqParamsJson)
  return "{true}";
end

function compileandreset(header,reqParamsJson)
  print ("compileandreset request received!!!! ");
  local filenamestoprocess ={};

  if reqParamsJson.filenames then
    filenamestoprocess = util.split(reqParamsJson.filenames,",");
  end

  if reqParamsJson then
    if reqParamsJson.merge and reqParamsJson.merge==true then

      file.remove(reqParamsJson.newfilename);

      print("Removed file "..reqParamsJson.newfilename);

      for idx=1,#filenamestoprocess do

        local fcontent = getfile(filenamestoprocess[idx]);

        file.open(reqParamsJson.newfilename,"a+");
        --file.write("\r\n");
        file.write(fcontent);
        file.close();
        print("Done with "..filenamestoprocess[idx]);
      end
      collectgarbage();
    end

    if reqParamsJson.removefiles and reqParamsJson.removefiles==true and filenamestoprocess then
      for idx=1,#filenamestoprocess do
        file.remove(filenamestoprocess[idx]);
        file.close();
        print("Removed file "..filenamestoprocess[idx]);
      end
    end
  end

  

   if reqParamsJson.compile and reqParamsJson.compile==true then
     print("Compile request received!!!! ");
     dofile("compiledelete.lua");
     collectgarbage();
     print("Done compilation !!!! ");
   end

   if reqParamsJson.restart and reqParamsJson.restart==true then
     print("Restart request received!!!! ");
     node.restart();
     print("Done Restarting !!!! ");
   end

  return "{true}";
end

function getfile(fileName)
  if not file.exists(fileName) then
    print("Looks like file is not present.",fileName);
    return false;
  end
  file.open(fileName, "r") ;
  local fileContent = file:read "*a";
  file.close();
  return fileContent;
end;

return config;
