#!/bin/bash

# file to be transfered
FILE_PATH="/path/to/your/file"
# receiver's IP 
RECEIVER_HOST="receiver_host"

# send a file to a remote server
scp $FILE_PATH $RECEIVER_HOST:~/received_file

# get file's size
FILE_SIZE=$(stat -c%s "$FILE_PATH")

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
# check the file's size on a remote host and await for approval
ssh $RECEIVER_HOST << EOF
RECEIVED_FILE_SIZE=\$(stat -c%s "~/received_file")

if [ \$RECEIVED_FILE_SIZE -eq $FILE_SIZE ]; then
    echo "File received successfully. Size match."
else
    echo "File size doesn't match. Something went wrong."
fi
EOF
