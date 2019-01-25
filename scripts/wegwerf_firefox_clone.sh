#!/bin/sh

set -o errexit
set -o nounset

PROFILEDIR=$(mktemp -p /tmp -d .tmp-fx-profile.XXXXXX.d)

if [ -d /home/seb/.mozilla/firefox/*.default-*/extensions/ ] ; then
	cd /home/seb/.mozilla/firefox/*.default-*/

	mkdir -p $PROFILEDIR/extensions 
	cp extensions/* $PROFILEDIR/extensions/
	cp addons.json extensions.json $PROFILEDIR/
	cp -R browser-extension-data $PROFILEDIR/

	test -f cert_override.txt \
		&& cp cert_override.txt $PROFILEDIR/

	#cp prefs.js $PROFILEDIR/
	echo 'user_pref("devtools.selfxss.count", 10);' > $PROFILEDIR/prefs.js

	cd -
fi

firefox -profile $PROFILEDIR -no-remote -new-instance
rm -rf $PROFILEDIR