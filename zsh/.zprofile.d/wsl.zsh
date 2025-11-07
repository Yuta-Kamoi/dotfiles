# ユーザーローカルなLinuxの慣習的バイナリをPATHの先頭に追加
path=(/usr/local/{bin,sbin} $path)

# Linuxbrewのパスを、現在のPATHのさらに先頭（最優先）に追加
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Google Drive (G:)を起動時に自動マウントする
# 既にマウントされていなければ実行
if ! mountpoint -q /mnt/g; then
  echo "G: ドライブをマウントします..."
  # 既存の /mnt/g が存在しない場合作成（通常は存在しますが念のため）
  [ ! -d /mnt/g ] && sudo mkdir -p /mnt/g
  
  # 手動で成功したコマンドを実行
  sudo mount -t drvfs G: /mnt/g
fi
