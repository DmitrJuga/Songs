### Songs
Тестовое задание выполнено.   
Ниже небольшие пояснения...
 
> Приложение должно скачивать песни, 

Скачивает. Работа с сетью - с помощью AFNetworking. Взаимодействие с серверным API вынесено в класс `SongsAPIManager`.

> сохранять их в БД (желательно, CoreData) 
    
Сохраняет в БД CoreData. Работа с CoreData с помощью MagicalRecord.   
В модели данных CoreData создана одна сущность Song c атрибутами, соответствующими JSON.

> и выводить в виде таблицы, где каждая ячейка состоит из Названия + Автора. 

Использую `UITableViewController` и кастомную ячейку (класс `SongTableViewCell`)

> Так же необходимо предусмотреть жест PullToRefresh, который обновляет с сервера данные таблицы. 

Есть, использую `RefreshControl`, встроенный в `UITableViewController`.   
Также сделал отдельную кнопу для обновления.

> Важным аспектом должно являться то, что новый список может как содержать новые песни, так и не иметь уже некоторых ранее загруженных. В случае, если при обновлении станет ясно, что часть песен удалилась с сервера, то их так же требуется удалить из таблицы и из базы.

Объединение списков сохранённых и загруженных песен реализовал в методе `mergeSongsFromList:` класса `SongsViewController`.
Распознаются добавленные, удалённые и изменённые песни. Алгорим: cначала сравниваются списки по id: если песня есть и в старом и в новом - проверяем не изменилась и удаляем из нового, если песня отстутсвует в новом - удаляем её из БД и из таблицы; оставшиеся в новом списке песни добавляем в БД и в таблицу. 

> Простым reloadData, естественно, не надо этот вопрос решать. Должны анимировано удаляться и добавляться ячейки. 

Удаляются и добавляются и обновляются анимировано, в том же методе `mergeSongsFromList:`, с разными видами анимации для каждой операции (`UITableViewRowAnimationXXXXX`).

> Приветствуется использование third-party инструментов, ускоряющих работу.

Использую три сторонних библиотеки, установленные через CocoaPods:
- [AFNetworking] (https://github.com/AFNetworking/AFNetworking)
- [MagicalRecord] (https://github.com/magicalpanda/MagicalRecord)
- [MBProgressHUD] (https://github.com/jdg/MBProgressHUD)

> Голую CoreData можешь даже не показывать.

Ok!) Пришлось разобраться с MagicalRecord...
