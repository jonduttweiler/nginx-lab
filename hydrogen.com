map $uri $key{
    "~/.*([a-fA-F0-9]{32}).*" $1;
    default '';
}

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

  location / {
    proxy_pass http://nodebackend/get-key/$key;
  }

}
