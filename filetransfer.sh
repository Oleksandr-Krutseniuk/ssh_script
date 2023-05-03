#!/bin/bash

# Имя файла и путь к нему
FILE_PATH="/home/ubuntu/testfile"
# IP или имя сервера-получателя
RECEIVER_HOST=54.187.59.142
RECEIVER_USER="ubuntu"
# Путь к файлу лога
LOG_FILE="/home/ubuntu/logfile.log"

# Отправка файла на сервер-получатель
scp $FILE_PATH $RECEIVER_USER@$RECEIVER_HOST:/home/ubuntu/received_file >> $LOG_FILE 2>&1

# Получение размера файла в битах
FILE_SIZE=$(stat -c%s "$FILE_PATH")

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
ssh -t $RECEIVER_USER@$RECEIVER_HOST << EOF 2>&1 | tee -a $LOG_FILE
RECEIVED_FILE_SIZE=\$(stat -c%s "/home/ubuntu/received_file")

if [ \$RECEIVED_FILE_SIZE -eq $FILE_SIZE ]; then
    echo "File received successfully. Size match."
else
    echo "File size doesn't match. Something went wrong."
fi
EOF
