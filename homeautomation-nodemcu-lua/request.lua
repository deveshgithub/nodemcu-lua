local request =  {}

function request.parseRequest(payload)

  local header={};

  local array = util.split(payload,"\n");


  local temp=array[1];
  local line1 = util.split(temp," ");

  --[[for n, w in ipairs(line1) do



    print(n .. ": " .. w)



  end--]]

  header.method=line1[1];
  header.action=line1[2];
  header.protocol=line1[3];
  header.contentType="";
 -- print(" -------- Headers Start ----------");
  --print("header.method : "..header.method);
  --print("header.action : "..header.action);
  --print("header.protocol : "..header.protocol);
  --print(" -------- Headers End   ----------");


  -- header["module"] = util.split(header.action,"/")[1];


  --header["action"] = util.split(header.action,"/")[2];

  header["module"],header["action"]=util.getmoduleandaction(header.action);

  if (header["action"]==nil or util.trim(header["action"])=="") then

    return false;

  end


  if (header["module"]==nil or util.trim(header["module"])=="") then

    return false;

  end


  local module = routeconfig[header.module];


  if (module==nil) then

    return false;

  end


  local action = module[header.action];



  header["route_config"] = action;

  local headersArray = {};

  local requestParamIdx=0;

  local boundary=nil;


  for idx = 2, #array-1 do

    headersArray = util.split(array[idx],":");

    header[headersArray[1]]=headersArray[2];

    --print(array[idx]);
    --Check if the headers are done
    --the request would come with \r followed by
    --request params
    local pos = string.find(headersArray[1], "\r")

    if pos and pos > 0 then
      print("Got carriage return .... "..idx);
      requestParamIdx=idx;
      break;
    end

  end


  if validation.validate(header)==false then

    return false;

  end

  header.params="";

  local boundary=ismultipartformdata(header);

  if(boundary) then

    processmultipartrequest(boundary,array,requestParamIdx);

  else
    pcall(function()

        for idx=requestParamIdx , #array do

          header.params =header.params..array[idx];

        end

    end

    )
  end
  --header.params=temp;

  print("Request Parameter Data Type : "..type(header["params"]));
   module=nil;boundary=nil;headersArray=nil;array=nil;
  return header;
end



function processmultipartrequest(boundary,array,startIdx)
  --print(boundary);
  --local startIdx = nil;
  local contentEndIdx=0;
  local contentStartIdx=0;

  local str="";
  local str1="";

  print("Start Printing");
  local boundarycontent=false;
  local filename=nil;
  local filescreated={};
  
  for index=startIdx,#array do

    boundarycontent=false;
    
    if(contentStartIdx<=0 and util.contains(array[index],boundary)) then
    

      contentStartIdx=index;
      boundarycontent=true;

    elseif (util.contains(array[index],boundary)) then
    
      contentEndIdx=index;
      boundarycontent=true;

    end
    
    if(index == contentStartIdx+1)then
       
      
      --print(filename);
      if(filename==nil) then
        filename=getfilename(array[index]);
        filename=util.trim(filename:gsub('"',''));
        
      end

      if file.open(filename) then
         file.close();     
         file.remove(filename);
         print("Removed File:: "..filename);   
         collectgarbage();
      end
      --file.remove();
     
      
      --file.open(filename, "w+") ;
      
    elseif(index == contentStartIdx+2) then
    
       file.open(filename,"w+");
    
    elseif(contentStartIdx>0  and boundarycontent==false and index > contentStartIdx+3) then
      --[[
      Content-Disposition: form-data; name="file1"; filename="compiledeletelua.lua"
      Content-Type: application/octet-stream

        ]]--
        --this is how the contents of file would be received when uploaded.
      file.writeline(array[index])  ;
      
    end

    
    print(contentEndIdx);
    
    if(contentEndIdx>0 and filename~=nil) then
      print("Closing File=> "..filename);
      --file.close();
      table.insert(filescreated,1,filename);
      contentStartIdx=-1;contentEndIdx=-1;boundarycontent=false;filename=nil;str1="";
      
    end

  end
  print(" File created / updated ::: ");



end

function ismultipartformdata(header)
  local contenttype=header["Content-Type"];
  if string.find(contenttype,"boundary",12,true) then
    local boundaryArr = util.split(contenttype,";");
    if(boundaryArr) then
      boundaryArr = util.split(boundaryArr[2],"=");
      local boundary=boundaryArr[2];
      print("We got the actual boundary string !!!! ");
      print(boundary);
      return boundary;
    end
  end
  return nil;
end

function getfilename(str)
  local arr=util.split(str,";");

  for idx=1,#arr do
    
    if(util.starts(util.trim(arr[idx]),"filename")) then
      local arr2 = util.split(arr[idx],"=");
      return arr2[2];
    end
  end
end


return request;
