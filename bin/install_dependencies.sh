#!/bin/bash

echo "Will first try to install virtualenv if not existing, will ask for sudo password"
sudo pip install virtualenv
sudo pip install virtualenv
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv --no-site-packages LawFactory
workon LawFactory
pip install simplejson
pip install html5lib
pip install beautifulsoup4
deactivate

