name             'fuelphp'
maintainer       'monosense'
maintainer_email 'maemichi@monosense.co.jp'
license          'All rights reserved'
description      'Installs/Configures fuelphp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apache2', '~> 3.2.2'
depends 'mysql', '~> 7.2.0'
depends 'php', '~> 1.9.0'
