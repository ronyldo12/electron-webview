#!/bin/zsh

check_error(){
    if ! [ "$1" = "0" ]; then
        print "\n\n\nERROR: $2\n\n"
        exit 1
    fi
}

source ~/.zshrc

APP_NODE_VERSION=v16.14.0
APP_ROOT_DIR=~/Downloads/
APP_NAME=$1
APP_URL=$2
ICON=$3

if [ -z "$APP_NAME" ]; then
  exit "app name is required"
fi

if [ -z "$APP_URL" ]; then
  exit "app url is required"
fi

type nvm 2> /dev/null 1> /dev/null
check_error $? "nvm is required. run sudo apt install nvm"

mkdir -p $APP_ROOT_DIR
APP_DIR=$APP_ROOT_DIR
APP_DIR="$APP_DIR$APP_NAME"

if [ -z "$ICON" ]; then
    ICON="assets/icons/default.png"
fi

BUILD_DIR=/tmp/$APP_NAME

mkdir -p $APP_DIR
check_error $? "cannot create app dir $APP_DIR"
mkdir -p $BUILD_DIR
check_error $? "cannot create app build dir $BUILD_DIR"

# nvm install $APP_NODE_VERSION
# check_error $? "error on install node $APP_NODE_VERSION"
# nvm use $APP_NODE_VERSION
# check_error $? "error on use node version $APP_NODE_VERSION"
#npm install -g electron-packager
#check_error $? "error on install electron-packager"

# npm install
# check_error $? "error on execute 'npm install'"

cp -rfp ./ $BUILD_DIR/
check_error $? "erro ao copiar arquivos do app"

cd $BUILD_DIR/ 
check_error $? "erro ao mover para o diretorio $BUILD_DIR"

if ! [[ "$ICON" == *.icns ]]; then
     print "the icon file must be a .png file"
     exit 1
fi

if [[ "$ICON" =~ ^http* ]]; then
    echo "\n\nDownloading icon from internet: $ICON\n\n"
    curl "$ICON" -o assets/icons/icon.png 1>/dev/null 2>/dev/null
    check_error $? "cannot download the icon $ICON"
fi

if ! [[ "$ICON" =~ ^http* ]]; then
    cp -fp $ICON assets/icons/icon.icns
fi

ICON="assets/icons/icon.icns"



if ! [ -f "$ICON" ]; then
  print "icon file don't found: $ICON"
  exit 1
fi

ICON="$APP_DIR/$APP_NAME-linux-x64/resources/app/$ICON"

echo "Icon: $ICON"

APP_URL_SED=$(echo $APP_URL | sed 's/\//\\\//g')
APP_DIR_SED=$(echo $APP_DIR | sed 's/\//\\\//g')
ICON_SED=$(echo $ICON | sed 's/\//\\\//g')

sed "s/{{APP_URL}}/$APP_URL_SED/g" -i main.js
check_error $? "erro ao definir url no index.html"
sed "s/{{APP_URL}}/$APP_URL_SED/g" -i src/view.js
check_error $? "erro ao definir url no src/view.js"
sed "s/{{ICON}}/$ICON_SED/g" -i src/window.js
check_error $? "erro ao definir icon no src/window.js"

sed "s/{{APP_NAME}}/$APP_NAME/g" -i package.json
check_error $? "erro ao definir url no package.json"

sed "s/{{APP_NAME}}/$APP_NAME/g" -i app.desktop
check_error $? "erro ao definir nome do app no app.desktop"
sed "s/{{APP_DIR}}/$APP_DIR_SED/g" -i app.desktop
check_error $? "erro ao definir nome do app no app.desktop"
sed "s/{{ICON}}/$ICON_SED/g" -i app.desktop
check_error $? "erro ao definir icon do app no app.desktop"


electron-packager . --overwrite --platform=darwin --arch=x64 --icon=assets/icons/icon.icns --prune=true --out=$APP_DIR/
check_error $? "you need to install electron-packager: npm install -g electron-packager"

print "instalado em: $APP_DIR/"


