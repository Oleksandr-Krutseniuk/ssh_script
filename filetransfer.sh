#!/bin/bash

# файл для відправки
FILE_PATH="/home/ubuntu/testfile6"
# адреса отримувача
RECEIVER_HOST=54.187.59.142
RECEIVER_USER="ubuntu" # користувач на ремоут-хості
LOG_FILE="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
dest_file="/home/ubuntu/received_file6" # місце і назва переданого файлу на ремоут-хості(отримувачі)
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S") # дата перевірки розмірів файлів
# Отправка файла на сервер-получатель
scp $FILE_PATH $RECEIVER_USER@$RECEIVER_HOST:$dest_file >> $LOG_FILE #2>&1

# Получение размера файла в битах
FILE_SIZE=$(stat -c%s "$FILE_PATH")

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
ssh -T $RECEIVER_USER@$RECEIVER_HOST << EOF | grep -E "File received successfully\. Size match\.|File size doesn't match\. Something went wrong\." >> $LOG_FILE
RECEIVED_FILE_SIZE=\$(stat -c%s "$dest_file")

if [ \$RECEIVED_FILE_SIZE -eq $FILE_SIZE ]; then
    echo "$CURRENT_DATE File received successfully. Size match."
else
    echo "$CURRENT_DATE File size doesn't match. Something went wrong."
fi
EOF
