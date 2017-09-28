#!/bin/bash
variable="$(getent group lightfoot | cut -d':' -f4)"
IFS=","
for name in $variable
do
getent passwd | egrep -i $name
  if [ $? -eq 0 ]; then
      /bin/bash -c "psql -U postgres -c \"CREATE USER $name;\"";
      /bin/bash -c "psql -U postgres -c \"CREATE DATABASE $name OWNER $name;\"";
  fi
done
