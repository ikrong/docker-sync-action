function login() {
    u=$(echo $2 | cut -d':' -f1)
    p=$(echo $2 | cut -d':' -f2-)
    if [ "$u" = "" ]; then
        return
    fi
    if [ "$p" = "" ]; then
        return
    fi
    echo "Login to $1"
    echo $p | skopeo login --password-stdin -u $u $1
    # 判断是否执行成功
    if [ $? -ne 0 ]; then
        echo "::error::Login to $1 failed"
        exit 1
    fi
}

function run_with_lines() {
    while read -r line; do
        if [ "$1" != "" ]; then
            $2 "$line"
        fi
    done <<< $(echo -e "$1" | tr ';' '\n')
}

function exec_skopeo() {
    if [ -f "${XDG_RUNTIME_DIR}/containers/auth.json" ]; then
      docker run --rm -v ${XDG_RUNTIME_DIR}/containers/auth.json:/auth.json -e "REGISTRY_AUTH_FILE=/auth.json" quay.io/skopeo/stable:latest $@
    else
      docker run --rm quay.io/skopeo/stable:latest $@
    fi
}

function sync() {
    echo "::group::Syncing $1"
    arr=($1 )
    exec_skopeo sync -a --src docker --dest docker "$SOURCE/${arr[0]}" "$DESTINATION/${arr[1]}"
    # 判断是否执行成功
    if [ $? -ne 0 ]; then
        echo "::error::Syncing $1 failed"
        echo "::endgroup::"
        exit 1
    fi
    echo "::endgroup::"
}

function copy() {
    echo "::group::Coping $1"
    arr=($1 )
    exec_skopeo copy -a all "docker://$SOURCE/${arr[0]}" "docker://$DESTINATION/${arr[1]}"
    # 判断是否执行成功
    if [ $? -ne 0 ]; then
        echo "::error::Coping $1 failed"
        echo "::endgroup::"
        exit 1
    fi
    echo "::endgroup::"
}

function install_latest_skopeo() {
    echo "::group::Pulling Latest Skopeo"
    docker pull quay.io/skopeo/stable:latest
    # 判断是否执行成功
    if [ $? -ne 0 ]; then
        echo "::error::Pulling Latest Skopeo failed"
        echo "::endgroup::"
        exit 1
    fi
    echo "::endgroup::"
}

install_latest_skopeo

docker -v
exec_skopeo --version

echo "::group::Login"
login $SOURCE $SOURCE_CREDENTIAL
login $DESTINATION $DESTINATION_CREDENTIAL
echo "::endgroup::"

if [ "$SYNC" != "" ]; then
    run_with_lines "$SYNC" sync
fi

if [ "$COPY" != "" ]; then
    run_with_lines "$COPY" copy
fi