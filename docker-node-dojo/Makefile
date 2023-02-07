
test:
	# Ensure netcat is installed, for checking availability of node servers
	nc -h 2>&1 | grep options:

	# Ensure mysql commands can be run
	mysql --version | grep "for Linux"

	# Test db-migrate node module
	db-migrate --version | grep 0\.11\.

	# Test node itself can be run
	yarn install --immutable
	node test.js

	# Test newman was successfully installed
	newman -v

	# Test Graphviz can be run
	dot -V
