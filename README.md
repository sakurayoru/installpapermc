# installpapermc
## papermc install scripts &amp; systemd unit files

## 環境
- RHEL系用に作成しています(RockyLinux8.5で動作確認済み)
- gitは事前に入れておいてください

## setup
- rootユーザーになってください
```
su - root
```
- clone してcdしてください
```
git clone https://github.com/sakurayoru/installpapermc.git
cd installpapermc
``` 
- setuppapermc.shを実行してください
```
sh setuppapermc.sh
```
- paperを実行するminecraft userが生成されます
- 必要なパッケージが自動で入ります
- デフォルトのポートが解放されます
- paperや起動スクリプトを保管するディレクトリが作成されます
- use paper base version?と聞かれるので1.18.1や1.17.1のように使いたいバージョンを入力してください
- 入力したバージョンの最終ビルドファイルがダウンロードされます
- eula true? or false?と聞かれるのでminecraftのeulaに同意する場合は"true"と入力してください
- shellscriptの移動が行われます
- /optの下のファイルの所有者をminecraftユーザーに変更されます
- systemd Unitファイルの移動とユニットの有効化が行われます
- これでこのスクリプトの実行が終わります
## その他情報
- ファイルの場所 /opt/mc/server /opt/mc/sh
- minecraftユーザーに切り替えてからscreen -rするとmcのコンソールに入れます