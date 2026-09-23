# installpapermc
## papermc install scripts &amp; systemd unit files

## 環境
- RHEL系用に作成しています(AlmaLinux9.5で動作確認済み)
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
- paperや起動スクリプトを保管するディレクトリが作成されます
- use paper base version?と聞かれるので1.18.1や1.17.1や26.2のように使いたいバージョンを入力してください
- 入力したバージョンの最終ビルドファイルとバージョンに対応したopenjdkがダウンロードされます
- Use minecraft Port No?と聞かれるので使用したいポートを入力します
- 対応するポートが解放されます
- Use MC Server name?と聞かれるので参加画面で表示したい文字列を入力してください
- 装飾など必要な場合は手動で`server.properties`を編集してください
- Use MC Server seed?と聞かれるので使用したいseed値を入力してください
- Use MC Server difficulty?と聞かれるのでhardなどの難易度を入力してください
- eula true? or false?と聞かれるのでminecraftのeulaに同意する場合は"true"と入力してください
- shellscriptの移動が行われます
- /optの下のファイルの所有者をminecraftユーザーに変更されます
- systemd Unitファイルの移動とユニットの有効化が行われます
- これでこのスクリプトの実行が終わります
## その他情報
- ファイルの場所 /opt/mc/server /opt/mc/sh
- minecraftユーザーに切り替えてからscreen -rするとmcのコンソールに入れます
