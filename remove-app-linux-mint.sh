#!/bin/zsh

check_error(){
    if ! [ "$1" = "0" ]; then
        print "$2"
        exit 1
    fi
}

source ~/.zshrc

APP_NODE_VERSION=v14.19.0
APP_ROOT_DIR=~/.electron-webview/
APP_NAME=$1

if [ -z "$APP_NAME" ]; then
  exit "app name is required"
fi


mkdir -p $APP_ROOT_DIR
APP_DIR=$APP_ROOT_DIR
APP_DIR="$APP_DIR$APP_NAME"


if ! [[ "$APP_DIR" == *.electron-webview/$APP_NAME* ]]; then
  print "$APP_DIR is invalid"
  exit 1
fi

if ! [ -d "$APP_DIR" ]; then
  print "app $APP_NAME not found in $APP_DIR"
  exit 1
fi




print $APP_DIR

rm -rf $APP_DIR

rm -f ~/.local/share/applications/$APP_NAME.desktop
rm -f ~/Área\ de\ Trabalho/$APP_NAME.desktop

