while read line; do
  echo $(psql -p 5432 -d highgo -c "$line")
done <$1
