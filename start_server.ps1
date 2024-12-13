# Определяем путь к приложению и имя процесса
$AppPath = "$(Get-Location)\bin\Content.Server\Content.Server.exe"
$ProcessName = "Content.Server"
$ResourcesFolder = "$(Get-Location)\Resources"
$ParentFolder = "$(Get-Location)\..\Resources"

# Функция для проверки наличия обновлений
function Check-GitUpdates {
    git fetch > $null 2>&1
    $localCommit = & git.exe rev-parse HEAD
    $remoteCommit = & git.exe rev-parse origin/HEAD

    if ($localCommit -ne $remoteCommit) {
        return $true
    } else {
        return $false
    }
}

# Функция для копирования папки Resources
function Copy-Resources {
    if (Test-Path $ResourcesFolder) {
        Write-Host "Копирую папку Resources в родительскую директорию..." -ForegroundColor Yellow
        Copy-Item -Path $ResourcesFolder -Destination $ParentFolder -Recurse -Force
        Write-Host "Папка Resources скопирована." -ForegroundColor Green
    } else {
        Write-Host "Папка Resources не найдена." -ForegroundColor Gray
    }
}


# Перезапускаем приложение
Write-Host "Запускаю приложение..." -ForegroundColor Yellow
Start-Process -FilePath $AppPath
Write-Host "Приложение запущено." -ForegroundColor Green

# Основной цикл
while ($true) {
    # Проверяем обновления
    if (Check-GitUpdates) {
        Write-Host "Найдены обновления. Останавливаю процесс..." -ForegroundColor Yellow

        # Останавливаем процесс
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Name $ProcessName -Force
            Write-Host "Процесс остановлен." -ForegroundColor Green
        } else {
            Write-Host "Процесс не найден." -ForegroundColor Gray
        }

        # Получаем обновления
        Write-Host "Получаю обновления из GIT..." -ForegroundColor Yellow
        & git.exe pull

        # Копируем папку Resources при обновлении
        #Copy-Resources

        # Перезапускаем приложение
        Write-Host "Перезапускаю приложение..." -ForegroundColor Yellow
        Start-Process -FilePath $AppPath
        Write-Host "Приложение перезапущено." -ForegroundColor Green
    } else {
        Write-Host "Обновлений не найдено." -ForegroundColor Gray
    }

    # Ждем 30 секунд
    Start-Sleep -Seconds 30
}
