## nginx default server block

server {
  listen     *:80;
  #listen   [::]:801 default_server ipv6only=off; ## listen for ipv6
	# our primary server name is the first, aliases simply come after it. you can also include wildcards like *.example.com
  server_name  example.com;
	root /var/www/example.com;

  server_name_in_redirect off;
  autoindex off;
	charset utf-8;
    	
	###############################################
    location / {
    index  index.php index.html index.htm;
		
    # the magic. this is the equivalent of all those lines you use for mod_rewrite in Apache
    # if the request is for "/foo", we'll first try it as a file. then as a directory. and finally
    # we'll assume its some sort of "clean" url and hand it to index.php so our CMS can work with it
    try_files $uri $uri/ /index.php$is_args$args;
    
	}
	###############################################
	
	# Let's Include Cache settings
	include     /etc/nginx/nomad-conf/cachestatic.add;
	
	#access_log  logs/host.access.log  main;
    
	# Preserve the port when redirects.
  port_in_redirect off;
   
  # Wordpress settings for /wordpress folder
	include   /etc/nginx/nomad-conf/wordpress.add;
   
  # include /etc/nginx/security;
  
  # Include the basic h5bp config set
  include   /etc/nginx/h5bp/basic.conf;
	
	# Let's Include PageSpeed
  include   /etc/nginx/nomad-conf/pagespeed.add;
	
	# PHP Settings
	include   /etc/nginx/nomad-conf/fastcgi.add;
	
	# Get real IP from Varnish and Cloudflare for Logging
	include   /etc/nginx/nomad-conf/realip.add;
	
	# Redirect server error pages to the static page /50x.html
	include   /etc/nginx/nomad-conf/serverror.add;
   
  # Deny access to htaccess files
  include   /etc/nginx/nomad-conf/deny-htaccess.add;
		
	# Varnish probe 
	include   /etc/nginx/nomad-conf/probe.add;
	
	# Let us not log favicon and robots and whatever
	include   /etc/nginx/nomad-conf/donotlog.add;
	
	# Create an /nginx-status page. 
	include   /etc/nginx/nomad-conf/status-stub.add;
}

