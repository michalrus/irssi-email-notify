#!/bin/sh

#
#   Copyright 2013 Michał Rus <m@michalrus.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

#
# Add this to your crontab
#

TO="m@michalrus.com"
FROM="scripts@michalrus.com"
DIR="${HOME}/.irssi/email-notify"

TMPFILE="${DIR}/"$(date +%s.%N)

/bin/ls "${DIR}/" | while read F ; do
	touch "${TMPFILE}" || eval 'echo "Could not touch ${TMPFILE}" ; exit 1'
	cat "${DIR}/${F}" >> "${TMPFILE}"
	rm -f "${DIR}/${F}"
done

if [ -f "${TMPFILE}" ] ; then
	(
		echo "From: Irssi <${FROM}>"
		echo "Subject: "$(date +%H:%M:%S)" -!- New hilights."
		echo
		cat "${TMPFILE}"
	) | /usr/sbin/sendmail "${TO}" && rm "${TMPFILE}"
fi
