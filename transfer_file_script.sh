#!/bin/bash   
 
source /home/ubuntu/var_file.txt # файл зі змінними, які імпортуються
# key= ключ для ssh-коннекту в файлі зі змінними var_file.txt
# port_number= номер порту ssh-коннекту в файлі зі змінними var_file.txt
# backup_host= адреса бекап хосту в файлі зі змінними var_file.txt 
# backup_user= remote -user в файлі зі змінними var_file.txt
# dbHost =                                     > в файлі зі змінними var_file.txt
# $dbUser =                                    > в файлі зі змінними var_file.txt
# $dbName =                                    > в файлі зі змінними var_file.txt
# $dbPassword =                                > в файлі зі змінними var_file.txt

file_path="/home/ubuntu/testfile" # файл для відправки


 
log_file="/home/ubuntu/logfile.log" # файл з результатом перевірки розміру файлу (відправлений=отриманий)
current_date=$(date +"%Y-%m-%d %H:%M:%S" ) # дата перевірки розмірів файлів
attempts=0 # для повідомлення про невдалі перевірки хеш-сум
max_attempts=5 # для зупинки скрипта при невдалій перевірці хеш-сум 5 разів


# безкінечний цикл для повторення віправки архіву на випадок, якщо хеш-суми не співпадуть
while true; do   
# архівація файлу
archive_name="$(basename ${file_path}).tar.gz" # тут буде назва файлу для архівації + ".tar.gz"
   
tar -czf "$archive_name" -C "$(dirname ${file_path})" "$(basename ${file_path})" &>/dev/null 2>&1 # скинуть вывод, ато он светится в терминале
#        | назва архіву    | місце файлу для архівації  | назва файлу для архівації
# команда має такий вигляд тому, що при використанні "-С" вказується директорія, в якій будуть розміщені файли для архівації, а сам
# файл можна вказувати з відносним шляхом (або просто назву).це призводить до того, що в архів буде поміщений тільки файл, а не
# дерево директорій "/home/user/file"
 


hashsum=$(sha256sum "$archive_name" | cut -d' ' -f1) # отримання хеш-суми архіву."cut" залишає тільки контрольну суму
# віправка файлу на сервер-отримувач
 
scp -i "$key" -P "$port_number" "$archive_name" "$backup_user@$backup_host:/home/ubuntu/$archive_name" > /dev/null # якщо потрібно - 
# можна створити змінну для місця зберігання. після scp у терміналі з'являється назва переданого файлу, що не потрібно для крон-джоби. 
# тому вивід іде в /dev/null 

# перевірка хеш-сум на ремоут-хості та виведення результату в лог-файл на хості-відправнику
 
received_hashsum=$(ssh -i "$key" -p "$port_number" $backup_user@$backup_host "sha256sum /home/ubuntu/$archive_name" | awk '{print $1}')
  if [ "$hashsum" = "$received_hashsum" ]; then # якщо хеш-суми однакові
    echo "$current_date File received successfully. Hashsum match." >> $log_file
    rm -f "$file_path" "$archive_name" # видаляє оригінальний файл та архів, якщо хеш-суми співпали
    break # завершує цикл якщо хеш-суми співпали
  else # хеш-сумми не співпали
    attempts=$((attempts+1)) # лічильник невдалих перевірок хеш-сум

      if [ "$attempts" -eq 1 ]; then # якщо перевірка хеш-сум провалена перший раз
        echo "$current_date Hashsum doesn't match. Something went wrong with $archive_name file." >> $log_file
      fi 

      if [ "$attempts" -eq "$max_attempts" ]; then # если 5 проверок хеш-сумм провалены
        echo "ATTENTION!!! $current_date Hashsums didn't match for $archive_name file after $attempts attempts" >> $log_file
        exit 1 # вихід зі скрипту якщо перевірка чек-сум провалилася 5 разів 
      fi

      if [ "$attempts" -ge 2 ]; then # 2 або більше невдалих перевірок хеш-сум
        echo "$current_date Hashsums didn't match for $archive_name file after $attempts attempts" >> $log_file
      fi


  fi

done