#!/usr/bin/sh

NAME=$1
TMP=$(mktemp)
FILE="$HOME/bin/connect-$NAME"

aj-snapshot -f -j $TMP



cat <<EOF > $FILE
#!/usr/bin/sh
cat << EOFF > $TMP
EOF

cat $TMP >> $FILE

cat <<EOF >> $FILE
EOFF
sleep 2
aj-snapshot -jx -r $TMP

EOF

chmod +x $FILE
