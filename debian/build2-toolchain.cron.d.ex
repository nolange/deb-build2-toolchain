#
# Regular cron jobs for the build2-toolchain package
#
0 4	* * *	root	[ -x /usr/bin/build2-toolchain_maintenance ] && /usr/bin/build2-toolchain_maintenance
