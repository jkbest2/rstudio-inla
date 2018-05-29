#!/bin/bash

# Created by argbash-init v2.5.1
# ARG_OPTIONAL_SINGLE([image])
# ARG_OPTIONAL_SINGLE([port])
# ARG_OPTIONAL_SINGLE([ip])
# ARG_OPTIONAL_SINGLE([name])
# ARG_OPTIONAL_BOOLEAN([testing])
# ARG_OPTIONAL_BOOLEAN([pull])
# ARG_HELP([<The general help message of my script>])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.5.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

die()
{
    local _ret=$2
    test -n "$_ret" || _ret=1
    test "$_PRINT_HELP" = yes && print_help >&2
    echo "$1" >&2
    exit ${_ret}
}

begins_with_short_option()
{
    local first_option all_short_options
    all_short_options='h'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}



# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_image="egonzalf/inla-stable-rstudio" # image based on rocker/rstudio
_arg_port=8787
_arg_ip=0.0.0.0
_arg_name=inla_rstudio
_arg_testing=off
_arg_pull=off

print_help ()
{
    printf "%s\n" "Run Docker container based on RStudio"
    printf 'Usage: %s [--image <arg>] [--port <arg>] [--ip <arg>] [--name <arg>] [--(no-)testing] [-h|--help]\n' "$0"
    printf "\t%s\n" "--image: Docker image to use. (Defaults to egonzalf/inla-stable-rstudio)"
    printf "\t%s\n" "--port: TCP port for Rstudio. (Defaults to 8787)"
    printf "\t%s\n" "--ip: IP address to attach the port to. (Defaults to 0.0.0.0)"
    printf "\t%s\n" "--name: Name for the Docker container. (Defaults to inla-rstudio)"
    printf "\t%s\n" "--testing: Use the 'testing' image egonzalf/inla-testing-rstudio"
    printf "\t%s\n" "--pull: Pull latest version of the docker image"
    printf "\t%s\n" "-h,--help: Prints help"
}

parse_commandline ()
{
    while test $# -gt 0
    do
        _key="$1"
        case "$_key" in
            --image)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_image="$2"
                shift
                ;;
            --image=*)
                _arg_image="${_key##--image=}"
                ;;
            --port)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_port="$2"
                shift
                ;;
            --port=*)
                _arg_port="${_key##--port=}"
                ;;
            --ip)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_ip="$2"
                shift
                ;;
            --ip=*)
                _arg_ip="${_key##--ip=}"
                ;;
            --name)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_name="$2"
                shift
                ;;
            --name=*)
                _arg_name="${_key##--name=}"
                ;;
            --no-testing|--testing)
                _arg_testing="on"
                test "${1:0:5}" = "--no-" && _arg_testing="off"
                ;;
            --no-pull|--pull)
                _arg_pull="on"
                test "${1:0:5}" = "--no-" && _arg_pull="off"
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -h*)
                print_help
                exit 0
                ;;
            *)
                _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
                ;;
        esac
        shift
    done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


# printf 'Value of --%s: %s\n' 'image' "$_arg_image"
# printf 'Value of --%s: %s\n' 'port' "$_arg_port"
# printf 'Value of --%s: %s\n' 'ip' "$_arg_ip"
# printf 'Value of --%s: %s\n' 'name' "$_arg_name"
# printf "'%s' is %s\n" 'testing' "$_arg_testing"

# ] <-- needed because of Argbash

######################################
######################################
######################################

IMAGE=$_arg_image
LOCAL_PORT=$_arg_port
LOCAL_IP=$_arg_ip
CONTAINER_NAME=$_arg_name


# MODIFY DEFAULT PASSWORD
unset PASSWORD;
while [ -z $PASSWORD ]; do
    echo "Please enter a new password for user 'rstudio': (WARNING: it will be printed on screen at the end.)"
    read -s PASSWORD
done

# VOLUME MOUNT PATH
while [ ! -d "$WORKDIR" ]; do
    echo ""
    echo "Type the path you like to use as working directory in RStudio (blank will use current path):"
    read WORKDIR
    [ -z $WORKDIR ] && WORKDIR=$PWD
done

# Testing image
if [ "$_arg_testing" == "on" ]; then
    IMAGE="egonzalf/inla-testing-rstudio:latest"
fi


# DOCKER
# If running, stop it
_status=`docker ps -f name=$CONTAINER_NAME --format "{{.Status}}" | wc -l`
[ $_status -gt 0 ] && docker stop $CONTAINER_NAME

set -e
if [ "$_arg_pull" == "on" ]; then
    echo "Pulling latest image..."
    docker pull $IMAGE
fi
echo "Starting Docker container..."
docker run --rm -d --name $CONTAINER_NAME -v $WORKDIR:/home/rstudio -p $LOCAL_IP:$LOCAL_PORT:8787 $IMAGE sh -c "usermod -u $UID rstudio; /init"
echo "rstudio:$PASSWORD" | docker exec -i $CONTAINER_NAME chpasswd

# SUMMARY
if [ "0.0.0.0" == "$LOCAL_IP" ]; then
    EXT_IP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
else
    EXT_IP="$LOCAL_IP"
fi
echo "================================================="
echo "RStudio is running on:"
echo "   http://$EXT_IP:$LOCAL_PORT/"
echo "   http://localhost:$LOCAL_PORT/"
echo "username:rstudio"
echo "password:$PASSWORD"
echo ""
echo "to stop RStudio type: docker stop $CONTAINER_NAME"
echo "================================================="

