#!/bin/bash          ЧЕРНОВИК(Попробовать запустить этот)

# файл для відправки
file_path="/home/ubuntu/testfile"
# адреса отримувача
receiver_host=34.220.97.124 
receiver_user="ubuntu" # користувач на ремоут-хості 
log_file="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
#dest_file="/home/ubuntu/received_file" # місце і назва переданого файлу на ремоут-хості(отримувачі)
current_date=$(date +"%Y-%m-%d %H:%M:%S") # дата перевірки розмірів файлів

# архивирование и дата архивации для последующей сортировки архивов (напр. для поиска бекапов по датам)
archive_name="${current_date}_$(basename ${file_path}).tar.gz"

tar -zcf $archive_name $file_path

# Отправка файла на сервер-получатель
scp $archive_name $receiver_user@$receiver_host:$archive_name >> $log_file  #возможно вывод в лог_файл можно убрать-протестить

# Получение размера файла в битах
file_size=$(stat -c%s "$archive_name") #поменять на сравнение размера архивов

# Отправка команды на сервер-получатель для проверки файла и ожидание подтверждения
ssh -T $receiver_user@$receiver_host << EOF | grep -E "File received successfully\. Size match\.|File size doesn't match\. Something went wrong\." >> $log_file
received_file_size=\$(stat -c%s "$archive_name")  

# тут:
-Т - вход без пароля; grep позволяет отсеять приветствие при выполнении ssh-команды и вывести только результаты цикла в файл

  if [ \$received_file_size -eq $file_size ]; then
    echo "$current_date File received successfully. Size match." # можно добавить имя архива, который был доставлен
  else
    echo "$current_date File size doesn't match. Something went wrong."
  fi
EOF

# в конце можно добавить удаление бекапа если условие тру-можно добавить цикл для сервера-отправителя. например:
#if [ $? -eq 0 ]; then
#    rm -f $archive_name
#fi
