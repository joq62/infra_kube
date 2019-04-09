%% service_info
%% Information of the servie
-record(state, {git_url,init_load_apps,keep_dirs}).

-define(WAIT_FOR_CONTROLLER,1000*20).

