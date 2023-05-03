#!/bin/bash

# Имя файла и путь к нему
FILE_PATH="/home/ubuntu/testfile5"
# IP или имя сервера-получателя
RECEIVER_HOST=54.187.59.142
RECEIVER_USER="ubuntu"
# Путь к файлу лога
LOG_FILE="/home/ubuntu/logfile.log"
dest_file="/home/ubuntu/received_file5"
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")
# Отправка файла на сервер-получатель
scp $FILE_PATH $RECEIVER_USER@$RECEIVER_HOST:$dest_file >> $LOG_FILE 2>&1

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
