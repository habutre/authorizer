#!/bin/sh

echo "Executing Authorizer app"
/app/authorizer

echo "Go to http://localhost/Authorizer.html to check the project documentation"
nginx -g 'daemon off;'


