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
    ICON="$APP_DIR/assets/icons/default.png"
fi

mkdir -p $APP_DIR

nvm install $APP_NODE_VERSION
check_error $? "erro ao instalar o nodejs $APP_NODE_VERSION"
nvm use $APP_NODE_VERSION
check_error $? "erro ao utilizar versão do nodejs $APP_NODE_VERSION"

npm install
check_error $? "erro baixar pacote 'npm install'"

cp -rfp ./ $APP_DIR/
check_error $? "erro ao copiar arquivos do app"

cd $APP_DIR/ 
check_error $? "erro ao mover para o diretorio $APP_DIR"


if ! [[ "$ICON" == *.png ]]; then
     print "the icon file must be a .png file"
     exit 1
fi

if [[ "$ICON" =~ ^http* ]]; then
    curl "$ICON" -o assets/icons/icon.png
    check_error $? "cannot download the icon $ICON"
fi

if ! [[ "$ICON" =~ ^http* ]]; then
    cp -fp $ICON assets/icons/icon.png
fi

ICON="$APP_DIR/assets/icons/icon.png"

echo "Icon: $ICON"

if ! [ -f "$ICON" ]; then
  print "icon file don't found: $ICON"
  exit 1
fi


APP_URL_SED=$(echo $APP_URL | sed 's/\//\\\//g')
APP_DIR_SED=$(echo $APP_DIR | sed 's/\//\\\//g')
ICON_SED=$(echo $ICON | sed 's/\//\\\//g')

sed "s/{{APP_URL}}/$APP_URL_SED/g" -i index.html
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


cp -rfp app.desktop ~/.local/share/applications/$APP_NAME.desktop
cp -rfp app.desktop ~/Área\ de\ Trabalho/$APP_NAME.desktop

electron-packager . --overwrite --platform=linux --arch=x64 --icon=assets/icons/default.png --prune=true --out=release-builds
check_error $? "você precisa instalar o electron-packager: npm -g electron-packager"

print "instalado em: $APP_DIR/"
