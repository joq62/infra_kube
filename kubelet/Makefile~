## set the paths for a default setup
all:
	erl -pa * -s loader start_loader -sname master;
#
# loader sim
loader_test:
	rm -rf test_ebin/* test_src/*~;
	erlc -o test_ebin test_src/*.erl
	erl -pa test_ebin -pa ebin -s test_node start -sname loader_sim

