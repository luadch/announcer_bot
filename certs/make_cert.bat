openssl req -x509 -nodes -days 3650 -subj /CN=Hub-Certificate -newkey rsa:1024 -keyout serverkey.pem -out servercert.pem
pause