$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Select-String:Encoding'] = 'utf8'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function logger {
    python $HOME\Documents\notes\ai_learning_os\scripts\run_logger.py @args
}

function logger-open {
    # 現在の時刻から1日マイナス（昨日）の日付を取得します
    $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    $path = "$HOME\Documents\notes\ai_learning_os\daily_notes\$yesterday.md"

    # VS Codeでファイルを開き、フォーカスを当てる
    if (!(Test-Path $path)) {
        ni $path
    }
    code -g "$path"
    (New-Object -ComObject WScript.Shell).AppActivate("Visual Studio Code")
}

function gcid {
    Get-ChildItem @args | Sort-Object LastWriteTime
}

# 過去すべての履歴（テキスト）を見るための関数を新設
function Get-AllHistory {
    Get-Content (Get-PSReadLineOption).HistorySavePath -Encoding utf8
}
# それには「gha」という別の名札をつける
Set-Alias gha Get-AllHistory

function nid {
    New-Item @args -ItemType Directory
}

# nvim コマンドで起動する設定
Set-Alias nvim "$HOME\Documents\nvim-win64\bin\nvim.exe"
Set-Alias vim "$HOME\Documents\nvim-win64\bin\nvim.exe"
