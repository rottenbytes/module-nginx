# @name : nginx
# @desc : classe de base pour nginx
# @info : nil
class nginx
{
	package { "nginx":
		ensure => installed
	}

	service { "nginx":
		ensure => running
	}

	file { "nginx.conf":
		name => "/etc/nginx/nginx.conf",
		owner => root,
		group => root,
		source => [ "puppet://$fileserver/files/apps/nginx/$fqdn/nginx-rp-secure.conf", "puppet://$fileserver/files/apps/nginx/nginx-rp-secure.conf"],
		ensure => present,
		notify => Service["nginx"]		
	}

	# status is installed on all nginx boxens
	file { "nginx-status":
		name => "/etc/nginx/sites-enabled/nginx-status",
		owner => root,
		group => root,
		source => [ "puppet://$fileserver/files/apps/nginx/nginx-status", "puppet://$fileserver/files/apps/nginx/$fqdn/nginx-status"],
		ensure => present,
		notify => Service["nginx"]
	}

	# include dir, get the freshness here
	file { "include_dir":
		name => "/etc/nginx/includes",
		owner => root,
		group => root,
		source => [ "puppet://$fileserver/files/apps/nginx/includes.$fqdn", "puppet://$fileserver/files/apps/nginx/includes"],
		ensure => directory,
		recurse => true,
		notify => Service["nginx"],
		ignore => ".svn*"
	}

	# files managed by hand, no matter if it breaks
	file { "sites-managed":
		name => "/etc/nginx/sites-managed",
		owner => root,
		group => root,
		ensure => directory
	}
}

# @name : nginx::reverseproxy
# @desc : config nginx pour reverse proxy
# @info : utilisée en conjonction avec dnsmasq local
class nginx::reverseproxy
{
	include nginx
	include dnsmasq::reverseproxy

	# Vars used by the template below
	$mysqldatabase=extlookup("mysqldatabase")
	$mysqllogin=extlookup("mysqllogin")
	$mysqlpassword=extlookup("mysqlpassword")
	$mysqlserver=extlookup("mysqlserver")

	file { "nginx-cachedir":
		name => "/dev/shm/nginx-cache",
		owner => www-data,
		group => www-data,
		ensure => directory
	}

	file { "site_reverse-proxy":
		name => "/etc/nginx/sites-enabled/reverse-proxy",
		owner => root,
		group => root,
		content => template("nginx/$fqdn/reverse-proxy.erb"),
		ensure => present,
		notify => Service["nginx"],
		require => File["nginx-cachedir"]
	}

}
