#!/bin/bash
# update clamd.conf and freshclam.conf from env variables

for OUTPUT in $(env | awk -F "=" '{print $1}' | grep "^CLAMD_CONF_"); do
    TRIMMED="${OUTPUT/CLAMD_CONF_/}"
    grep -q "^$TRIMMED " /etc/clamd.d/scan.conf && sed "s/^$TRIMMED .*/$TRIMMED ${!OUTPUT}/" -i /etc/clamd.d/scan.conf ||
        sed "$ a\\$TRIMMED ${!OUTPUT}" -i /etc/clamd.d/scan.conf
done

for OUTPUT in $(env | awk -F "=" '{print $1}' | grep "^FRESHCLAM_CONF_"); do
    TRIMMED="${OUTPUT/FRESHCLAM_CONF_/}"
    grep -q "^$TRIMMED " /etc/freshclam.conf && sed "s/^$TRIMMED .*/$TRIMMED ${!OUTPUT}/" -i /etc/freshclam.conf ||
        sed "$ a\\$TRIMMED ${!OUTPUT}" -i /etc/freshclam.conf
done
