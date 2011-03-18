maintainer       "The Concord Consortium"
maintainer_email "aunger@concord.org"
license          "All rights reserved"
description      "Installs/Configures a complete geniverse server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "cc_rails_app"
depends "tomcat"
depends "monit"
depends "apache2"
