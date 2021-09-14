# docker
* Установка докера:

Обновим состав установочных пакетов, чтобы иметь представление об их актуальных версиях:

`$ sudo apt-get update`

Предварительно установим набор пакетов, необходимый для доступа к репозиториям по протоколу HTTPS:

**- apt-transport-https** — активирует передачу файлов и данных через https;

**- ca-сertificates** — активирует проверку сертификаты безопасности;

**- curl** — утилита для обращения к веб-ресурсам;

**- software-properties-common** — активирует возможность использования скриптов для управления программным обеспечением.

`$ sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common`

Далее добавим в систему GPG-ключ для работы с официальным репозиторием Docker:

`$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

Повторно обновим данные о пакетах операционной системы:

`$ sudo apt-get update`

Приступаем к установке пакета Docker.

`$ sudo apt-get install -y docker-ce docker-ce-cli`

После завершения установки запустим демон Docker и добавим его в автозагрузку:

`$ sudo systemctl start docker`

`$ sudo systemctl enable docker`