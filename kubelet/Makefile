## set the paths for a default setup
all:
	erlc -o test_ebin src/*.erl test_src/*erl;
	rm test_ebin/*;
	erlc -o test_ebin src/*.erl test_src/*erl;
	cp src/*.app test_ebin;
	erl -pa test_ebin -s test_kubelet test -sname test_kubelet;
#
# loader sim
loader_test:
	rm -rf test_ebin/* test_src/*~;
	erlc -o test_ebin test_src/*.erl
	erl -pa test_ebin -pa ebin -s test_node start -sname loader_sim

