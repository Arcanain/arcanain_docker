# Arcanain Docker

ROS2 開発用の Docker 環境。`setup.sh` で CPU/GPU を自動判別し、適切な compose ファイルを選んで起動します。

## 必要環境
- Docker / Docker Compose v2
- (GPU 利用時) NVIDIA ドライバ + nvidia-container-toolkit がホストに導入済み

## クイックスタート
```bash
# ビルドしてバックグラウンド起動 (GPU があれば自動で GPU 用を選択)
./setup.sh up -d --build

# GPU を強制使用 (検出に関係なく GPU 用 compose)
USE_GPU=1 ./setup.sh up -d --build

# CPU を強制使用
USE_GPU=0 ./setup.sh up -d --build
```
実行ログに `Compose mode: GPU` / `CPU` が出るので選択結果を確認できます。

## ワークスペースパス
- デフォルト: `/home/<user>/ros2_docker` をホスト側に作成・マウント
- 変更したい場合: `ROS_PROJECT_PATH=/path/to/ros2_ws ./setup.sh up -d --build`

## コンテナ操作の例
```bash
# 停止と削除
./setup.sh down

# ログを見る
./setup.sh logs -f

# シェルに入る (ros_dev_env は service 名)
./setup.sh exec ros_dev_env bash
```

## ROS2 確認コマンド
```bash
# コンテナ起動後に実行（ros2 を使うときは毎回 setup.bash を source）

# ROS ディストリビューションとインストールバージョン確認
# ※ ros2 CLI には --version がないため、ROS_DISTRO と Debian パッケージで確認します
./setup.sh exec ros_dev_env bash -lc "source /opt/ros/${ROS_DISTRO:-humble}/setup.bash && echo ROS_DISTRO=$ROS_DISTRO && dpkg -l | grep \"ros-$ROS_DISTRO-desktop\""

# 診断レポート
./setup.sh exec ros_dev_env bash -lc "source /opt/ros/${ROS_DISTRO:-humble}/setup.bash && ros2 doctor --report"

# トピック一覧 (ROS_DISTRO は humble がデフォルト)
./setup.sh exec ros_dev_env bash -lc \"source /opt/ros/${ROS_DISTRO:-humble}/setup.bash && ros2 topic list\"
```

※ `./setup.sh up -d --build` でコンテナを起動してから実行してください。ノードが動いていない場合は `ros2 topic list` が空（`/rosout` など最小限）になります。

## GUI/NoVNC
- X11 をホスト共有。NoVNC はポート `8080` (docker-compose.*.yml の設定) で利用可能。
- NoVNC URL: `http://localhost:8080` (ブラウザからアクセス)

## メモ
- CPU 用 compose は GPU をパススルーしません。GPU を使う場合は `USE_GPU=1` で GPU compose を選択してください。
- `setup.sh` 以外に `docker compose -f docker-compose.*.yml ...` を直接呼ぶことも可能ですが、環境変数のデフォルト設定は `setup.sh` が簡単です。
