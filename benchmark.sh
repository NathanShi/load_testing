#!/usr/bin bash

# -------------------------------
# Load Tests with different tools
# - Apache Benchmark: built in for mac, https://httpd.apache.org/docs/2.4/programs/ab.html
# - Siege: `brew install siege`, https://github.com/JoeDog/siege
# - weighttp: could also be used, but it's not supporting ssl/https.

DIVIDER="\n--------------------------\n--------------------------\n"
DATE=$(date)
if [ ! -d "benchmark_result" ]
then
  mkdir "./benchmark_result"
fi

# Settings:
SITE="https://www.google.com/"
OUTFILES="./benchmark_result/ab_result.txt ./benchmark_result/siege_result.txt"
TIMEOUT=200
# TOTAL_REQUEST: For each round, how many request in total you would like to load?
TOTAL_REQUEST=20
# CONCURRENT_USER_ARRAY: For each round, how many concurrent user you would like to simulate?
CONCURRENT_USER_ARRAY=( 1 5 10 20 )
# --- Other settings:
# AUTH=""         # add '-A' tag for ab
# HTTP_METHOD=""  # add '-m' tag
# CONTENT_TYPE="" # add '-T' tag
# HEADER=""       # add '-H' tag for siege
# PUT_BODY=""     # add '-u' tag
# POST_BODY=""    # add '-p' tag
# ---

# Benchmark START:
echo "Benching: $SITE"
echo "Start Time: $DATE"
for FILE in $OUTFILES; do
  touch $FILE
  echo "Benching: $SITE" > $FILE
  echo "Start Time: $DATE" >> $FILE
  echo $DIVIDER >> $FILE
done

for round in ${!CONCURRENT_USER_ARRAY[@]}; do
  echo "Round $(( $round + 1 )): "
  echo "${CONCURRENT_USER_ARRAY[round]} concurrent users doing $TOTAL_REQUEST page hits."

  for FILE in $OUTFILES; do
    echo "Round $(( $round + 1 )): " >> $FILE
    echo "" >> $FILE
    echo "Result of $TOTAL_REQUEST page loads by ${CONCURRENT_USER_ARRAY[round]} concurrent users." >> $FILE
    echo "" >> $FILE
  done

  # apache benchmark
  ab -r -n $TOTAL_REQUEST -c ${CONCURRENT_USER_ARRAY[round]} -s $TIMEOUT $SITE >> ${OUTFILES[0]}

  # siege
  siege -c${CONCURRENT_USER_ARRAY[round]} -r$((TOTAL_REQUEST / ${CONCURRENT_USER_ARRAY[round]})) -d10s $SITE >> ${OUTFILES[1]}

  for FILE in $OUTFILES; do
    echo $DIVIDER >> $FILE
  done
done

DATE=$(date)
echo "End Time: $DATE" >> $FILE
