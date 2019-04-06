## set the paths for a default setup
all:
#
#	Infrastructure
#loader
	erlc -o loadpackage/loader loader/src/*.erl;
	cp loader/src/*.app loadpackage/loader;
	rm loadpackage/loader/*.beam;
	rm loadpackage/loader/*.app;
	rm test/loader/*;
	erlc -o loadpackage/loader loader/src/*.erl;
	cp loader/src/*.app loadpackage/loader;
	cp loadpackage/loader/* test/loader;
#lib
	erlc -o loadpackage/lib lib/src/*.erl;
	rm loadpackage/lib/*.beam;
	rm loadpackage/lib/*.app;
	erlc -o loadpackage/lib lib/src/*.erl;
	cp lib/src/*.app loadpackage/lib;
#
#dns
	erlc -o loadpackage/dns dns/src/*.erl;
	cp dns/src/*.app loadpackage/dns;
	rm loadpackage/dns/*.beam;
	rm loadpackage/dns/*.app;
	erlc -o loadpackage/dns dns/src/*.erl;
	cp dns/src/*.app loadpackage/dns;
#
#kubelet
	erlc -o loadpackage/kubelet kubelet/src/*.erl;
	cp kubelet/src/*.app loadpackage/kubelet;
	rm loadpackage/kubelet/*.beam;
	rm loadpackage/kubelet/*.app;
	erlc -o loadpackage/kubelet kubelet/src/*.erl;
	cp kubelet/src/*.app loadpackage/kubelet;
#
#controller
	erlc -o loadpackage/controller controller/src/*.erl;
	cp controller/src/*.app loadpackage/controller;
	rm loadpackage/controller/*.beam;
	rm loadpackage/controller/*.app;
	erlc -o loadpackage/controller controller/src/*.erl;
	cp controller/src/*.app loadpackage/controller;
#
#applog
	erlc -o loadpackage/applog applog/src/*.erl;
	cp applog/src/*.app loadpackage/applog;
	rm loadpackage/applog/*.beam;
	rm loadpackage/applog/*.app;
	erlc -o loadpackage/applog applog/src/*.erl;
	cp applog/src/*.app loadpackage/applog;
#

#
#  	Nodes
#
# master
	rm nodes/node_master/loader/*;
	cp loadpackage/loader/* nodes/node_master/loader;
# asus_100
	rm nodes/node_asus_100/loader/*;
	cp loadpackage/loader/* nodes/node_asus_100/loader;
# asus_101
	rm nodes/node_asus_101/loader/*;
	cp loadpackage/loader/* nodes/node_asus_101/loader;
# asus_102
	rm nodes/node_asus_102/loader/*;
	cp loadpackage/loader/* nodes/node_asus_102/loader;
# rpi_1
	rm nodes/node_rpi_1/loader/*;
	cp loadpackage/loader/* nodes/node_rpi_1/loader;
#
# rpi_2
	rm nodes/node_rpi_2/loader/*;
	cp loadpackage/loader/* nodes/node_rpi_2/loader;
#
# test_node
	rm  nodes/test_node/ebin/*;
	cp loadpackage/lib/*     nodes/test_node/ebin;
	cp loadpackage/dns/*   	 nodes/test_node/ebin;
	cp loadpackage/kubelet/* nodes/test_node/ebin;
	cp loadpackage/controller/*  nodes/test_node/ebin;
	cp loadpackage/applog/*  nodes/test_node/ebin;
	cp loadpackage/loader/*  nodes/test_node/ebin;
#
#	END
#
	echo ++ END build_succeded ++;
#
#  test code
system:
	rm -rf test_ebin/* test_src/*~;
	erlc -o test_ebin test_src/*.erl;
	cp test_src/*.app test_ebin;
	erl -pa test_ebin -pa nodes/test_node/ebin -s sys_lib start -sname test_system
