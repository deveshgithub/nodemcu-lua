files = file.list();


routeconfig={};

function init()

    local CONFIG_FILE="config.json";
    STATUS_FILE="status.json";
   --STATUS_TEMPLATE_FILE="statustemplate.json";
    local USERS_FILE="registeredusers.json";
    local MAC_FILE="registeredmacs.json";

    local ROUTE_MAC_FILE="route_mac_req.json";
    local ROUTE_STATUS_FILE="route_status_req.json";
    local ROUTE_CONFIG_FILE="route_config_req.json";
    local ROUTE_USER_FILE="route_user_req.json";
    
    config=getDataFromFile(CONFIG_FILE);
    print("Loaded Config !!!");
    --print(config);
    --registeredmacs=getDataFromFile("registeredmacs.json");
    --print("Loaded Registered MAC Addresses!!");
    --registeredusers=getDataFromFile("registeredusers.json");
    --print("Loaded Registered Users !!");
    savedstatus=getDataFromFile(STATUS_FILE);
    --print("Loaded Last Saved Status !!");

    --Below key is the module name 
    --like mac , status , config , user
    --the url will be like 
    --http://192.168.128.108/status/getstatus
    --status is the module and getstatus action mapping is present in 
    --ROUTE_STATUS_FILE
    --the mapping must be status.getstatus.
    --routeconfig["mac"]=getDataFromFile(ROUTE_MAC_FILE);
    routeconfig["status"]=getDataFromFile(ROUTE_STATUS_FILE);
    routeconfig["config"]=getDataFromFile(ROUTE_CONFIG_FILE);
    --routeconfig["user"]=getDataFromFile(ROUTE_USER_FILE);

   
    --print("Loaded routeconfig !!");

        CONFIG_FILE=nil;
        --STATUS_FILE=nil;
        USERS_FILE=nil;
        MAC_FILE=nil;
        ROUTE_MAC_FILE=nil;
        ROUTE_STATUS_FILE=nil;
        ROUTE_CONFIG_FILE=nil;
        ROUTE_USER_FILE=nil;
        collectgarbage();
end
-- Returns data as Json from given file and closes the file.
function getDataFromFile(fileName)
    print(" fileName ."..fileName);
    if not file.exists(fileName) then
        print("Looks like file is not present.",fileName);
        return "{}";
    end
    file.open(fileName, "r") ;
    local fileContent = file:read "*a";
    --print(fileName.." Below are the File Contents ::: ");
    --print(fileContent);
    local tempData="{}";
    
    if (fileContent) then
        tempData=cjson.decode(fileContent);    
    end;
    file.close();
    file=nil;
    collectgarbage();
    return tempData;
end;

function updateFile(fileName,content,openMode)
    if not file.exists(fileName) then
        print("Looks like file is not present.",fileName);
        return "{}";
    end
    
    file.open(fileName, openMode) ;
    
    file.write(content);

    file.close();

    file.open(fileName, "r") ;
    
    local fileContent = file.read();
    
    local tempData={};
    
    if (fileContent) then
    
        tempData=cjson.decode(fileContent);    
        
    end;
    
    file.close();
    
    return tempData;
end
init();
collectgarbage();
