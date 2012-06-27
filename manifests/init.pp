#
# This is reliant on the PKI module.
class ldap ($ldap, $ldap_base, $ca_cert){
	package { "openldap-clients" :
		ensure => installed,
	}

	file { "/etc/openldap/ldap.conf" :
		owner => "root",
		group => "root",
		mode => 644,
		content => template("ldap/ldap.conf.erb"),
		require => Package["openldap-clients"],
	}

	# System Bundle
	# XXX: It's easier to just copy the file if the link doesn't exist 
	exec { "cp_ca-bundle.crt":
		command => "cp -p /etc/pki/tls/certs/ca-bundle.crt /etc/openldap/cacerts/ca-bundle.crt",
		unless => "test -f /etc/openldap/cacerts/ca-bundle.crt && cmp /etc/pki/tls/certs/ca-bundle.crt /etc/openldap/cacerts/ca-bundle.crt",
	}

	file { "/etc/openldap/cacerts/ca-bundle.crt":
		owner => "root",
		group => "root",
		mode => 0644,
		require => Exec["cp_ca-bundle.crt"],
	}

	exec { "hash_ca-bundle.crt" :
		command => "ln -s /etc/openldap/cacerts/ca-bundle.crt /etc/openldap/cacerts/$(openssl x509 -noout -hash -in /etc/openldap/cacerts/ca-bundle.crt).0",
		unless => "test -L /etc/openldap/cacerts/$(openssl x509 -noout -hash -in /etc/openldap/cacerts/ca-bundle.crt).0",
		refreshonly => true,
		subscribe => File["/etc/openldap/cacerts/ca-bundle.crt"],
	}

	file { "/etc/openldap/cacerts/straycat.crt":
		owner => "root",
		group => "root",
		mode => 0644,
		source => $ca_cert,
	}

	exec { "hash_straycat.crt" :
		command => "ln -s /etc/openldap/cacerts/straycat.crt /etc/openldap/cacerts/$(openssl x509 -noout -hash -in /etc/openldap/cacerts/straycat.crt).0",
		unless => "test -L /etc/openldap/cacerts/$(openssl x509 -noout -hash -in /etc/openldap/cacerts/straycat.crt).0",
		refreshonly => true,
		subscribe => File["/etc/openldap/cacerts/straycat.crt"],
	}
}
