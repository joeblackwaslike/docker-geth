# Helpers

function get-name {
    local name=$(basename $PWD)
    if echo "$name" | grep -q docker; then
        name=$(echo "$name" | cut -d'-' -f2)
    fi
    echo "$name"
}

# Creates a stable branch identifier when executing CI on pull requests.
function get-branch {
    if [[ ! -z $TRAVIS ]]; then
        if [[ $TRAVIS_PULL_REQUEST == 'false' ]]; then
            export BRANCH=$TRAVIS_BRANCH
        else
            export BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
        fi
    fi
    printf "${BRANCH:=$(basename $(git status | head -1 | awk '{print $NF}'))}"
}

function get-tag {
    local branch=$(get-branch)
    if [[ $branch == 'master' ]]; then
        printf 'latest'
    else
        printf $branch
    fi
}

function get-user {
    printf ${DOCKER_USER:=telephoneorg}
}

function get-docker-image {
    local user=$(get-user)
    local name=$(get-name)
    local tag=$(get-tag)
    printf "$user/$name:$tag"
}

# Actions

function tag {
    if [[ -z $1 ]]; then
        printf 'Usage: %s <new-tag>\n' $0
    fi
    local new_tag="$1"
    local name=$(get-name)
    local user=$(get-user)
    local image=$(get-docker-image)
    docker tag $image $user/$name:$new_tag
}

function hub-push {
    local name=$(get-name)
    local user=$(get-user)
    local image
    if [[ ! -z $DOCKER_ORG ]]; then
        image=$DOCKER_ORG/$name
    else
        image=$user/$name
    fi
    if [[ -z $user || -z $DOCKER_PASS ]]; then
        printf 'DOCKER_USER/PASS environment variable not set\n'
        return 1
    fi
    docker login -u $user -p $DOCKER_PASS
    docker push $image
}

function hub-trigger {
    if [[ -z $BUILD_TOKEN ]]; then
        printf 'BUILD_TOKEN not set.\n'
        return 1
    fi
    local name=$(get-name)
    local tag=$(get-tag)
    local user=$(get-user)
    curl -s -X POST -H "Content-Type: application/json" \
    	--data '{"docker_tag": "$tag"}' \
    	https://registry.hub.docker.com/u/$user/$name/trigger/$BUILD_TOKEN/
}

function clone-deps {
    local org='sip-li'
    local dep
    if [[ ! -z "$@" ]]; then
        printf "Cloning deps: $@\n"
        for dep in "$@"; do
            pushd ..
            git clone https://github.com/$org/docker-${dep}
            popd
        done
    fi
}

function pull-deps {
    local user=$(get-user)
    local dep
    if [[ ! -z "$@" ]]; then
        printf "Pulling deps: $@\n"
        for dep in "$@"; do
            docker pull $user/$dep
        done
    fi
}

function ci-tag-build {
    if [[ -z $TRAVIS ]]; then
        printf 'Not in CI environment!\n'
        return 1
    fi
    tag ${TRAVIS_COMMIT::6}
    tag travis-$TRAVIS_BUILD_NUMBER
}

export NAME=$(get-name)
export BRANCH=$(get-branch)
export TAG=$(get-tag)
export DOCKER_USER=$(get-user)
export DOCKER_IMAGE=$(get-docker-image)

echo -e "
NAME: $NAME
BRANCH: $BRANCH
TAG: $TAG
DOCKER_USER: $DOCKER_USER
DOCKER_IMAGE: $DOCKER_IMAGE
"
