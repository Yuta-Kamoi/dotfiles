#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

##############################
# Customize to your needs... #
##############################
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# 保管機能を有効にして、実行する
autoload -Uz compinit
if [[ -n ~/.zcompdump ]]; then
  compinit -C
else
  compinit
fi

# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# cd無しでもディレクトリ移動
setopt auto_cd

# cd -で以前移動したディレクトリを表示
setopt auto_pushd

# コマンドのスペルをミスして実行した場合に候補を表示
setopt correct

# 履歴設定
HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=10000
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# 起動時に他にシェルが起動していなければtmux起動
# [[ -z "$TMUX" && ! -z "$PS1" ]] && tmux
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--ansi --height=100% --info=inline --border"

# enhancdを有効化
source ~/ghq/github.com/b4b4r07/enhancd/init.sh
# "cd ..", "cd -"の挙動をデフォルトにもどし、代わりに-up,-lsを設定
ENHANCD_HYPHEN_ARG="-ls"
ENHANCD_DOT_ARG="-up"
. "$HOME/ghq/github.com/b4b4r07/enhancd/init.sh"

# gotoを有効化
source ~/ghq/github.com/iridakos/goto/goto.sh

# kを有効化
source ~/ghq/github.com/supercrabtree/k/k.sh

# エージェントが起動していない、または鍵が登録されていない場合に処理を実行
# VSCodeのターミナル用のSSHエージェントの永続化ロジック
# 起動情報を保存するファイル
AGENT_ENV="$HOME/.ssh/agent.env"
# 1. 環境ファイルが存在し、かつエージェントが生きているか確認
if [ -f "${AGENT_ENV}" ]; then
    . "${AGENT_ENV}" > /dev/null 2>&1
    
    # 環境変数を読み込んだ後、PIDが存在し、かつプロセスが動いているか再チェック
    if ! kill -0 "$SSH_AGENT_PID" > /dev/null 2>&1; then
        # プロセスが死んでいたらファイルを削除し、再起動させる
        rm -f "${AGENT_ENV}"
    fi
fi
# 2. エージェントが起動していない場合、新規起動
if [ ! -f "${AGENT_ENV}" ]; then
    # 新しいエージェントを起動し、情報をファイルに保存
    ssh-agent -s > "${AGENT_ENV}"
    . "${AGENT_ENV}" > /dev/null 2>&1
    
    # 鍵を登録（このとき一度だけパスフレーズが求められる）
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        ssh-add "$HOME/.ssh/id_ed25519" > /dev/null 2>&1
    fi
fi


############
# コマンド #
############

#################
# WSLのみの設定 #
#################
if [[ "$(uname)" == 'Linux' ]]; then
  if [[ "$(uname -r)" == *microsoft* || "$(uname -r)" == *Microsoft* ]]; then

    # lsの色を変える.dircolorsを適用
    eval $(dircolors -b ~/.dircolors)

    # WSL: macのopen風（PowerShell一本化）
    open() {
      if [[ $# -eq 0 ]]; then
        explorer.exe .
        return
      fi

      for arg in "$@"; do
        # URL は & を含むので PowerShell 経由がラク
        if [[ "$arg" =~ '^[A-Za-z]+://' ]]; then
          powershell.exe -NoProfile -Command "Start-Process '$arg'"
          continue
        fi

        # パス: 相対はそのまま、絶対(~,/で開始)は Windows 形式に変換
        if [[ "$arg" = /* || "$arg" = ~* ]]; then
          cmd.exe /c start "" "$(wslpath -w "$arg")"
        else
          cmd.exe /c start "" "$arg"
        fi
      done
    }

    # Google Driveアプリを動的に探して起動する関数 (Windows形式パスに変換)
    gdrive-start() {
    local GD_BASE="/mnt/c/Program Files/Google/Drive File Stream"
    local WIN_BASE="C:\\Program Files\\Google\\Drive File Stream" # Windows形式のベースパス

    # 1. 最新のバージョン番号のディレクトリを動的に検索 (Linuxパスで検索)
    local LATEST_VERSION_DIR
    LATEST_VERSION_DIR=$(find "$GD_BASE" -maxdepth 1 -type d -name "[0-9]*" | tail -1)

    if [ -z "$LATEST_VERSION_DIR" ]; then
        echo "Error: Google Drive File Streamのバージョンフォルダが見つかりませんでした。"
        return 1
    fi

    # 2. 実行ファイルのフルパスをLinux形式で取得
    local LINUX_EXE_PATH="$LATEST_VERSION_DIR/GoogleDriveFS.exe"

    # 3. LinuxパスをWindowsパスに変換する
    # LATEST_VERSION_DIRから /mnt/c を取り除き、残りの / を \ に置換し、WIN_BASEと結合
    local VERSION_SUBPATH=${LINUX_EXE_PATH#$GD_BASE} # /116.0.6.0/GoogleDriveFS.exe の部分
    
    # WSL環境で使える sed で / を \\ に置換し、WIN_BASEと結合（Windowsパスの \ はエスケープが必要）
    local WIN_EXE_PATH="${WIN_BASE}${VERSION_SUBPATH//\//\\}"

    # 4. Windowsの start コマンドを使用して、Windows形式のパスを起動
    if [ -x "$LINUX_EXE_PATH" ]; then
        echo "Google DriveをWindowsプロセスとして起動します..."
        # Windowsの start コマンドに、変換した Windows形式のパスを渡す
        /mnt/c/Windows/System32/cmd.exe /C start "" "$WIN_EXE_PATH"
    else
        echo "Error: 実行ファイルが見つからないか、権限がありません: $LINUX_EXE_PATH"
        return 1
    fi
    }

    # ===== Obsidian opener (WSL) =====
    export OB_VAULT_NAME="notes"
    export OB_VAULT_PATH="$HOME/notes"

    _obsi_urlencode() {
      python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"
    }

    obsi() {
      # 引数なし → ボールトを開く
      if [[ $# -eq 0 ]]; then
        powershell.exe -NoProfile -Command "Start-Process 'obsidian://open?vault=${OB_VAULT_NAME}'"
        return
      fi

      local target="$1" rel

      # 絶対/ホームパスならボールト相対に直す
      if [[ "$target" = /* || "$target" = ~* ]]; then
        rel="$(realpath --relative-to="$OB_VAULT_PATH" "$target" 2>/dev/null)" || {
          echo "not under vault: $target" >&2; return 1; }
      else
        rel="$target"
      fi

      local enc="$(_obsi_urlencode "$rel")"
      powershell.exe -NoProfile -Command "Start-Process 'obsidian://open?vault=${OB_VAULT_NAME}&file=${enc}'"
    }
  fi
fi


#################
# MACのみの設定 #
#################
if [[ "$OSTYPE" == darwin* ]]; then
  # NAS接続コマンドを実行 (パスワードは対話形式で入力)
  function connect_nas() {
    mount_smbfs "//admin@192.168.1.21/share" "$HOME/NAS" 2>/dev/null
  }

  # ---- Obsidian 設定 ----
  export OB_VAULT_NAME="notes"        # Obsidian の“ボールト名”（UIに出る表示名）
  export OB_VAULT_PATH="$HOME/notes"  # ボールトの実体パス（例: /Users/you/notes）

  # URLエンコード（日本語/スペース対応）
  _obsi_urlencode() {
    python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$1"
  }

  # 絶対/ホームパス → ボールト直下からの相対パスに変換（外なら失敗）
  _obsi_to_vault_rel() {
    python3 -c '
  import os, sys
  vault = os.path.abspath(os.path.expanduser(sys.argv[1]))
  p     = os.path.abspath(os.path.expanduser(sys.argv[2]))
  if os.path.commonpath([p, vault]) != vault:
      sys.exit(1)
  print(os.path.relpath(p, vault))
  ' "$OB_VAULT_PATH" "$1"
  }

  # obsi: Obsidian で開く
  #  - 引数なし: ボールトだけ開く
  #  - 引数あり: file= に渡す（相対はそのまま。/ や ~ で始まる絶対は vault 相対に変換）
  #  - 日本語/スペースは自動でURLエンコード
  obsi() {
    if [[ $# -eq 0 ]]; then
      open "obsidian://open?vault=${OB_VAULT_NAME}"
      return
    fi

    local target="$1" rel

    if [[ "$target" = /* || "$target" = ~* ]]; then
      rel="$(_obsi_to_vault_rel "$target")" || {
        echo "not under vault: $target" >&2
        return 1
      }
    else
      rel="$target"
    fi

    local enc="$(_obsi_urlencode "$rel")"
    open "obsidian://open?vault=${OB_VAULT_NAME}&file=${enc}"
  }
fi
