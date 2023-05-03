#!/bin/bash

# файл для відправки
file_path="/home/ubuntu/testfile7"
# адреса отримувача
receiver_host=54.187.59.142 
receiver_user="ubuntu" # користувач на ремоут-хості 
log_file="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
dest_file="/home/ubuntu/received_file7" # місце і назва переданого файлу на ремоут-хості(отримувачі)
current_date=$(date +"%Y-%m-%d %H:%M:%S") # дата перевірки розмірів файлів
# Отправка файла на сервер-получатель
scp $file_path $receiver_user@$receiver_host:$dest_file >> $log_file  

# Получение размера файла в битах
file_size=$(stat -c%s "$file_path")

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
ssh -T $receiver_user@$receiver_host << EOF | grep -E "File received successfully\. Size match\.|File size doesn't match\. Something went wrong\." >> $log_file
received_file_size=\$(stat -c%s "$dest_file")  

if [ \$received_file_size -eq $file_size ]; then
    echo "$current_date File received successfully. Size match."
else
    echo "$current_date File size doesn't match. Something went wrong."
fi
EOF
