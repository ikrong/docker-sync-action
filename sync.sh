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

function sync() {
    echo "::group::Syncing $1"
    arr=($1 )
    skopeo --debug sync --multi-arch all --src docker --dest docker "$SOURCE/${arr[0]}" "$DESTINATION/${arr[1]}"
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
    skopeo --debug copy --multi-arch all "docker://$SOURCE/${arr[0]}" "docker://$DESTINATION/${arr[1]}"
    # 判断是否执行成功
    if [ $? -ne 0 ]; then
        echo "::error::Coping $1 failed"
        echo "::endgroup::"
        exit 1
    fi
    echo "::endgroup::"
}

function install_latest_skopeo() {
    echo "::group::Install Skopeo"
    echo 'deb http://download.opensuse.org/repositories/home:/alvistack/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:alvistack.list
    curl -fsSL https://download.opensuse.org/repositories/home:alvistack/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_alvistack.gpg > /dev/null
    sudo apt update
    sudo apt -o Dpkg::Options::="--force-overwrite" install skopeo
    echo "::endgroup::"
}

install_latest_skopeo

docker -v
skopeo -v

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