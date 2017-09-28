group_arr=""
variable="$(getent group lightfoot | cut -d':' -f4)"
IFS=","
for name in $variable
do
getent passwd | egrep -i $name
  if [ $? -eq 0 ]; then
    group_arr+=$(getent group | grep $name | cut -d: -f1 | awk 'BEGIN { ORS = " " } { print }')  
  fi
done
group_uniq=$(echo $group_arr | tr " " "\n" | sort | uniq | tr "\n" " ")
#echo "$group_uniq"

IFS=" "
for group in $group_uniq
do
  group_fixed=$(echo $group | tr "-" "_")
  /bin/bash -c "psql -U postgres -c \"CREATE ROLE $group_fixed;\"";

  for name in $variable
  do
  getent passwd | egrep -i $name
    if [ $? -eq 0 ]; then
      in_group=$(getent group | grep $name | cut -d: -f1 | awk 'BEGIN { ORS = " " } { print }' | grep -c "$group ")
      if [ in_group -eq 0 ]; then
        /bin/bash -c "psql -U postgres -c \"GRANT $group_fixed TO $name;\"";
      fi
    fi
  done
done
