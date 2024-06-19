function login() {
    echo "Login to $1"
    u=$(echo $2 | cut -d':' -f1)
    p=$(echo $2 | cut -d':' -f2-)
    if [ "$u" = "" ]; then
        return
    fi
    if [ "$p" = "" ]; then
        return
    fi
    echo $p | skopeo login --password-stdin -u $u $1
}

function run_with_lines() {
    echo $1 | while IFS= read -r line; do
      $2 "$line"
    done
}

function sync() {
    echo "Syncing $1"
    arr=($1 )
    skopeo sync --src docker --dest docker "$SOURCE/${arr[0]}" "$DESTINATION/${arr[1]}"
}

function copy() {
    echo "Coping $1"
    arr=($1 )
    skopeo copy "docker://$SOURCE/${arr[0]}" "docker://$DESTINATION/${arr[1]}"
}

login $SOURCE $SOURCE_CREDENTIAL

login $DESTINATION $DESTINATION_CREDENTIAL

if [ "$SYNC" != "" ]; then
    run_with_lines "$SYNC" sync
fi

if [ "$COPY" != "" ]; then
    run_with_lines "$COPY" copy
fi