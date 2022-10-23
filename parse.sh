grep "[0-9] mapped (" $1 | sed 's/^.*mapped/mapped/' | tr -d -c "0-9." > final_result.txt
