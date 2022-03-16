### ZFS
Запускаем виртуальную с помощью команды:
```
vagrant up
```
Заходим на сервер:
```
vagrant ssh
```
# Определение алгоритма с наилучшим сжатием
Список дисков на виртуальной машине мы можем посмотреть с помощью команды `lsblk`
Создаем пул из дисков в режиме RAID 1:
```
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
```
Смотрим информацию о пулах: `zpool list`
```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
```
Далее добавим разные алгоритмы сжатия в каждую файловую систему:
```
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
```
Проверим, FS на различные методы сжатия: 
```
zfs get all | grep compression
otus1  compression           lzjb                       local
otus2  compression           lz4                        local
otus3  compression           gzip-9                     local
otus4  compression           zle                        local

```
Далее скачиваем один и тот же файл во все пулы :
```
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```
Проверяем что файл скачан
```
ls -l /otus*
/otus1:
итого 22018
-rw-r--r--. 1 root root 40792737 мар  2 09:00 pg2600.converter.log

/otus2:
итого 17971
-rw-r--r--. 1 root root 40792737 мар  2 09:00 pg2600.converter.log

/otus3:
итого 10948
-rw-r--r--. 1 root root 40792737 мар  2 09:00 pg2600.converter.log

/otus4:
итого 39866
-rw-r--r--. 1 root root 40792737 мар  2 09:00 pg2600.converter.log
```
Проверяем,  сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия
```
zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.7M   330M     21.5M  /otus1
otus2  17.7M   334M     17.6M  /otus2
otus3  10.9M   341M     10.7M  /otus3
otus4  39.1M   313M     39.0M  /otus4
```
```
zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.81x                      -
otus2  compressratio         2.22x                      -
otus3  compressratio         3.64x                      -
otus4  compressratio         1.00x                      -
```
Как мы видим алгоритм `gzip-9` самый эффективныйпо сжатию
# Определение настроек пула
Скачиваем архив в home директорию и разархивируем его
```
wget -O archive.tar.gz --no-check-certificate https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
tar -xzvf archive.tar.gz

```
Проверим, возможно ли импортировать данный каталог в пул:
```
zpool import -d zpoolexport/
pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
	some features will not be available without an explicit 'zpool upgrade'.
 config:

	otus                                 ONLINE
	  mirror-0                           ONLINE
	    /home/vagrant/zpoolexport/filea  ONLINE
	    /home/vagrant/zpoolexport/fileb  ONLINE
```

Cделаем импорт данного пула и проверим статус о составе ипортированного пула:
```
zpool import -d zpoolexport/ otus
zpool status
```
# Работа со снапшотом, поиск сообщения от преподавателя
Скачаем файл, указанный в задании:
```
wget -O otus_task2.file --no-check-certificate https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
```
Востанавливаем FS из снапшота:
```
zfs receive otus/test@today < otus_task2.file
```
Ищем в каталоге `/otus/test файл с именем “secret_message”:
```
find /otus/test -name "secret_message" 
/otus/test/task1/file_mess/secret_message
```
Посмотрим содержимое файла:
```
cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```

