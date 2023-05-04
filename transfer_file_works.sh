#!/bin/bash          ЧЕРНОВИК(Попробовать запустить этот)

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


hashsum=$(sha256sum "$archive_name" | cut -d' ' -f1) # отримання хеш-суми архіву."cut" залишає тільки контрольну суму
# віправка файлу на сервер-отримувач 
scp "$archive_name" "$receiver_user@$receiver_host:/home/ubuntu/$archive_name" # якщо потрібно - можна створити змінну для місця зберігання


# вычисление SHA256-хеш-суммы полученного файла на удаленном сервере и сравнение со значением отправленной хеш-суммы

ssh $receiver_user@$receiver_host "sha256sum /home/ubuntu/$archive_name" | awk '{print $1}' | grep "$hashsum" > /dev/null 2>&1 && \
echo "$current_date File received successfully. Hashsum match." >> $log_file || \
echo "$current_date Hashsum doesn't match. Something went wrong." >> $log_file
# на ремоут-хості перевіряється хеш-сума архіву, "awk" вирізає саме значення суми з stdout а grep шукає в виводі "awk" змінну $hashsum, яка
# яка містить хеш-суму архіву, отриману до відправки на хості-віправнику.якщо результат роботи grep=0,виконується перша echo,якщо не 0-то друга 



# в конце можно добавить удаление бекапа если условие тру-можно добавить цикл для сервера-отправителя. например:
#if [ $? -eq 0 ]; then
#    rm -f $archive_name + сам файл с бекапом
#fi
# Архив создается там, откуда запускается команда