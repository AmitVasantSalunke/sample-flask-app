#!/usr/bin/env bash

INPUT_VALUE=$1
BASE_DIR=$PWD

rm -rf $BASE_DIR/tmp

#### Setup PATH Variables
function setup_path(){
    echo "Setting up path variables.........................................................................."

    export OPENSSL_PATH="$BASE_DIR/env/openssl"
    export PYTHON_PATH="$BASE_DIR/env/python"
    export VENV_PATH="$BASE_DIR/env/virtual"
    export TMP_PATH="$BASE_DIR/tmp"
    export DOWNLOAD_CACHE="$BASE_DIR/download-cache"
    export PATH=$PATH:$PYTHON_PATH:$VENV_PATH:$OPENSSL_PATH

}

#### Setup directory structure
function setup_directory_structure()
{
    echo "Setting up directory structure....................................................................."
    mkdir -p $BASE_DIR/bin
    mkdir -p $BASE_DIR/env
    mkdir -p $BASE_DIR/env/openssl
    mkdir -p $BASE_DIR/env/python
    mkdir -p $BASE_DIR/env/virtual
    mkdir -p $BASE_DIR/var/log
    mkdir -p $BASE_DIR/download-cache
    mkdir -p $BASE_DIR/tmp
}


#### Setup os packages
function setup_os_packages()
{
    echo "Installing system packages....................................................................."
    os=`uname`
    if [ $os = "Linux" ]
    then
        sudo yum install -y --quiet libxml2 libxml2-devel libxslt libxslt-devel libcurl-devel yum-utils 
        sudo yum install -y --quiet libssh2 libssh2-devel centos-release-scl libffi-devel bison-devel gcc-c++
        sudo yum install -y --quiet zlib-devel openssl-devel gcc autoconf automake bzip2-devel readline-devel
        sudo yum install -y --quiet openldap-devel protobuf-compiler python-devel libaio mysql-devel uuid-devel
        sudo yum install -y --quiet make cmake python-devel pkgconfig bison curl unzip zip telnet
    else
        echo "Unsupported OS"
        exit 1
    fi
}

#### Download pre-requisites
function download()
{
    cd $DOWNLOAD_CACHE

    options=($(echo $1 | sed 's/^,//' | sed 's/,$//' | tr "," " "))
    for option in ${options[@]}
    do
        case $option in
            openssl)
                echo "Downloading openssl..........................................................................."
                curl -L -o openssl.tar.gz https://www.openssl.org/source/openssl-1.0.2l.tar.gz
                ;;
            python3)
                echo "Downloading python3............................................................................"
                curl -L -o python.tgz https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz
                ;;
            all)
                download "openssl,python3"
                ;;
        esac
    done
}

#### Setup openssl
function setup_openssl()
{
    rm -rf $BASE_DIR/env/openssl
    mkdir -p $BASE_DIR/env/openssl

    if [ !  "$(ls -A $OPENSSL_PATH)"  ]
    then
        echo "Installing openssl....................................................................."
        rm -rf $TMP_PATH/openssl
        cd $TMP_PATH && mkdir -p $TMP_PATH/openssl
        tar --strip 1 -xvzf $DOWNLOAD_CACHE/openssl.tar.gz -C $TMP_PATH/openssl
        cd $TMP_PATH/openssl
        ./$openssl_config -fPIC  no-hw --prefix=$OPENSSL_PATH --openssldir=$OPENSSL_PATH
        make && make install

    fi
}

#### Setup python
function setup_python()
{
    rm -rf $BASE_DIR/env/python
    mkdir -p $BASE_DIR/env/python

    if [ !  "$(ls -A $PYTHON_PATH)"  ]
    then
        echo "Installing python....................................................................."
        rm -rf $TMP_PATH/python
        cd $TMP_PATH && mkdir -p $TMP_PATH/python
        tar --strip 1 -xvzf $DOWNLOAD_CACHE/python.tgz -C $TMP_PATH/python
        cd $TMP_PATH/python
        ./configure CPPFLAGS="-I$OPENSSL_PATH/include" LDFLAGS="-L$OPENSSL_PATH/lib" --prefix=$BASE_DIR/env/python
        make && make install
    fi
}

#### Setup venv
function setup_venv()
{
    rm -rf $BASE_DIR/env/virtual
    mkdir -p  $BASE_DIR/env/virtual

    if [ !  "$(ls -A $VENV_PATH)" ]
    then
        echo "Creating virtual env....................................................................."
        cd $BASE_DIR
        $PYTHON_PATH/bin/python3 -m venv $VENV_PATH
        source $VENV_PATH/bin/activate
        $VENV_PATH/bin/pip3 install wheel zc.buildout 
        $VENV_PATH/bin/pip3 install -r requirements.txt
        
    fi

}

#### Setup environment
function setup_environment()
{
    echo "Running env.... $1"
    options=($(echo $1 | sed 's/^,//' | sed 's/,$//' | tr "," " "))
    for option in ${options[@]}
    do
        case $option in
            openssl)
                setup_openssl
                ;;
            python)
                setup_python
                ;;
            venv)
                setup_venv
                ;;
            all)
                setup_openssl
                setup_python
                setup_venv
                ;;
        esac
    done

}

setup_path
setup_directory_structure

for option in $INPUT_VALUE
do
    arg_name=`echo $option | cut -f1 -d=`
    arg_val=`expr "X$option" : '[^=]*=\(.*\)'`

    case $arg_name in
        os-packages)
            setup_os_packages
            ;;
        download)
            download $arg_val
            ;;
        env)
            setup_environment $arg_val
            ;;
        all)
            setup_os_packages
            download "all"
            setup_environment "all"
            ;;
    esac
done



