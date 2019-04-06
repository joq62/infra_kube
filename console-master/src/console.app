{application, console,
 [{description, " console"},
  {vsn, "1.0.0"},
  {modules, [console_app,
             console_sup,
	     console_lib,
	     console]},
  {registered, [console]},
  {applications, [kernel, stdlib]},
  {mod, {console_app, []}}
 ]}.
