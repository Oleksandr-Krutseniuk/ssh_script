#!/bin/bash          РАБОЧАЯ ВЕРСИЯ С ПРОВЕРКОЙ ПО БАЙТАМ

# файл для відправки
file_path="/home/ubuntu/testfile"
# адреса отримувача
receiver_host=34.220.97.124 
receiver_user="ubuntu" # користувач на ремоут-хості 
log_file="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
current_date=$(date +"%Y-%m-%d %H:%M:%S" ) # дата перевірки розмірів файлів

  
# архівація файлу
archive_name="$(basename ${file_path}).tar.gz" # тут буде назва файлу для архівації + ".tar.gz"
 
tar -czf "$archive_name" -C "$(dirname ${file_path})" "$(basename ${file_path})" # скинуть вывод, ато он светится в терминале
#        | назва архіву    | місце файлу для архівації  | назва файлу для архівації

# віправка файлу на сервер-отримувач 
scp "$archive_name" "$receiver_user@$receiver_host:/home/ubuntu/$archive_name" # якщо потрібно - можна створити змінну для місця зберігання

# розмір в бітах
file_size=$(stat -c%s "$archive_name") #поменять на сравнение размера архивов

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
ssh -T $receiver_user@$receiver_host << EOF | grep -E "File received successfully\. Size match\.|File size doesn't match\. Something went wrong\." >> $log_file
# grep буде виводити тільки строки з значеннями з циклу if (цикл нижче) 
 
received_file_size=\$(stat -c%s "/home/ubuntu/$archive_name")



  if [ \$received_file_size -eq $file_size ]; then
    echo "$current_date File received successfully. Size match." # можно добавить имя архива, который был доставлен
  else
    echo "$current_date File size doesn't match. Something went wrong."
  fi
EOF