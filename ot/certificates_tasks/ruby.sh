#!/bin/bash

>&2 echo "Trying to run "
>&2 echo -e "ruby $@ "
>&2 echo " "

if [ -x /opt/gitlab/embedded/bin/ruby ]; then
	>&2 echo -e "/opt/gitlab/embedded/bin/ruby $@ "
	/opt/gitlab/embedded/bin/ruby "$@"
	exit $?
fi

if [ -x /usr/local/bin/ruby ]; then
	>&2 echo -e "/usr/local/bin/ruby $@ "
	/usr/local/bin/ruby "$@"
	exit $?
fi

OTHER=$(which ruby)
if [ -z "${OTHER}" ] && [ "" != "${OTHER}" ] && [ -x "${OTHER}" ]; then
	>&2 echo -e "${OTHER} $@ "
	${OTHER} "$@"
	exit $?
fi

>&2 echo "ruby $@ "
ruby "$@"
exit $?

