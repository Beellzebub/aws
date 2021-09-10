# git
* Установка гита:

`$ sudo apt install git`

* Конфигурация:

Изменение общих настроек для всех пользователей системы.
Конфигурационный файл - etc/gitconfig.

`$ sudo git config --system`

Изменение настроек для текущего пользователя системы.
Конфигурационный файл - ~/.gitconfig или ~/.config/git/config.

`$ git config --global`

Изменение настроек для текущего репозитория.
Конфигурационный файл - .git/config.

`$ git config --local`

Просмотр всех настроек и места, где они заданы.

`$ git config --list --show-origin`

Просмотр используемой конфигурации.

`$ git config --list`

Установка необходимых параметров.

`$ git config --global user.name "Name"` - имя

`$ git config --global user.email name@example.com` - почта