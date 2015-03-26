Rails.application.config.middleware.use OmniAuth::Strategies::LDAP,
  title: 'seldlx3031_apache_ds', host: 'localhost', port: 10389, method: 'plain', base: 'ou=seldlx3031_apache_ds,dc=example,dc=com', uid: 'cn', bind_dn: 'uid=admin,ou=system', password: 'secret'
