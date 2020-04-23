#!/bin/bash
set -m

export PATH=/usr/pgsql-12/bin:$PATH

# Initialise Environment Variables
SOURCE_DIR="$HOME/sources/wal2mongo"

# Exit code for this script
retval=0

ExecuteCommand()
{
	eval ${@}
	r=$?

	if [[ $r -ne 0 ]];
	then
		echo "${@} returned nonzero error code [$r]."
		exit $r
	fi
}

PushD()
{
	ExecuteCommand "pushd $@"
}

PopD()
{
	ExecuteCommand "popd"
}

checkout_sources()
{
	echo "Checking out wal2mongo"
	git clone https://github.com/HighgoSoftware/wal2mongo.git "$SOURCE_DIR"
}

package_make()
{
	PushD ${SOURCE_DIR}
	echo "Compiling wal2mongo"
	ExecuteCommand "USE_PGXS=1 make CLANG=/usr/bin/clang with_llvm=no"
	PopD
}

package_make_install()
{
	PushD ${SOURCE_DIR}
	echo "Installing wal2mongo"
	ExecuteCommand "sudo -E env "PATH=$PATH" USE_PGXS=1 make CLANG=/usr/bin/clang with_llvm=no install"
	PopD
}


build()
{
	echo "Starting build wal2mongo"
	checkout_sources
	package_make
	package_make_install
	retval=$?
}


# main
build

exit $retval
