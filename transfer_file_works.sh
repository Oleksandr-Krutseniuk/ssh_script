#!/bin/bash          ЧЕРНОВИК(Попробовать запустить этот)

# файл для відправки
file_path="/home/ubuntu/testfile"
# адреса отримувача
receiver_host=34.220.97.124 
receiver_user="ubuntu" # користувач на ремоут-хості 
log_file="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
current_date=$(date +"%Y-%m-%d %H:%M:%S" ) # дата перевірки розмірів файлів
attempts=0 # для повідомлення про 2> невдалі перевірки хеш-сум


# безкінечний цикл для повторення віправки архіву на випадок, якщо хеш-суми не співпадуть
while true; do   
# архівація файлу
archive_name="$(basename ${file_path}).tar.gz" # тут буде назва файлу для архівації + ".tar.gz"
   
tar -czf "$archive_name" -C "$(dirname ${file_path})" "$(basename ${file_path})" &>/dev/null 2>&1 # скинуть вывод, ато он светится в терминале
#        | назва архіву    | місце файлу для архівації  | назва файлу для архівації
 


hashsum=$(sha256sum "$archive_name" | cut -d' ' -f1) # отримання хеш-суми архіву."cut" залишає тільки контрольну суму
# віправка файлу на сервер-отримувач 
scp "$archive_name" "$receiver_user@$receiver_host:/home/ubuntu/$archive_name" > /dev/null # якщо потрібно - можна створити змінну для місця зберігання


# перевірка хеш-сум на ремоут-хості та виведення результату в лог-файл на хості-відправнику

received_hashsum=$(ssh $receiver_user@$receiver_host "sha256sum /home/ubuntu/$archive_name" | awk '{print $1}')
  if [ "$hashsum" = "$received_hashsum" ]; then # якщо хеш-суми однакові
    echo "$current_date File received successfully. Hashsum match." >> $log_file
    rm -f "$file_path" "$archive_name" # видаляє оригінальний файл та архів, якщо хеш-суми співпали
    break # завершує цикл якщо хеш-суми співпали
  else # хеш-сумми не співпали
    attempts=$((attempts+1)) # лічильник невдалих перевірок хеш-сум
    echo "$current_date Hashsum doesn't match. Something went wrong with $archive_name file." >> $log_file
      if [ "$attempts" -ge 2 ]; then # 2 або більше невдалих перевірок хеш-сум
        echo "$current_date Hashsums didn't match for $archive_name file after $attempts attempts" >> $log_file
      fi
  fi

done