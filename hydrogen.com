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
    
  location ~* "/fetch/([a-fA-F0-9]{32})$" {
    set $key $1;
    proxy_pass http://nodebackend;
  }

}
