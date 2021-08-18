
test:
	# Ensure netcat is installed, for checking availability of node servers
	nc -h 2>&1 | grep netcat
	# Ensure mysql commands can be run
	mysql --version | grep "for Linux"
	# Test node itself can be run
	yarn install --frozen-lockfile && node test.js
	# Test newman was successfully installed
	newman -v
