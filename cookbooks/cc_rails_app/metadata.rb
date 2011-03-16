maintainer       "The Concord Consortium"
maintainer_email "aunger@concord.org"
license          "All rights reserved"
description      "Installs/Configures various CC rails apps"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "apache2"
depends "rails"
depends "bundler"
depends "xslt"
depends "xml"
depends "unzip"
