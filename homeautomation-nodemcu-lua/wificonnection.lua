local util=require("util");

wifi.sta.disconnect();

wifi.setmode(wifi.STATION);

wifi.sta.autoconnect(1);

wifi.sta.config(config.wifi.wifissid,config.wifi.wifipwd);
wifi.sta.sethostname(config.wifi.hostname) ;
util=nil;
