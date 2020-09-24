map $uri $key{
    "~/.*([a-fA-F0-9]{32}).*" $1;
    default '';
}

log_format notes '[$time_iso8601] ' 
		             '$remote_addr $scheme "$request" $status '
                 'key:$key upstream:$upstream_addr';

upstream nodebackend {
  hash $key consistent;
  server localhost:3001;
  server localhost:3002;
  server localhost:3003;
}

server {
  listen 80;
  listen [::]:80;

  server_name hydrogen.com;

  access_log /var/log/nginx/notes.log notes;
  location / {
    proxy_pass http://nodebackend/get-key/$key;
  }

}
