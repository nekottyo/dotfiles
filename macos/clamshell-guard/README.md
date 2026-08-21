# clamshell-guard

蓋を閉じたときのスリープを、信頼できるネットワークでだけ止める LaunchDaemon。

## 解決したい問題

MacBook は蓋を閉じると Clamshell Sleep に入る。長時間タスクを回したまま蓋を閉じると途中で止まる。

`caffeinate` では防げない。`caffeinate -i` が立てる `PreventUserIdleSystemSleep` は無操作時間の経過によるスリープを抑止するもので、蓋閉じは別経路のため素通りする。Electron の `powerSaveBlocker` を使うツール類も内部は同じ IOPMAssertion なので同様に効かない。

効くのは `pmset disablesleep` だけ。ただしこれは電源ソース別に持てない。`-c` を付けても plist の `SystemPowerSettings` に書かれ、バッテリー駆動時にも適用される。

```
"SystemPowerSettings" => {
    "SleepDisabled" => true
}
```

そのまま有効にすると、カバンに入れて持ち歩く間も蓋を閉じたまま動き続けて発熱する。条件判定を外側に置いて自動で戻す必要がある。

## 判定条件

物理ゲートウェイの MAC アドレスに応じて `disablesleep 1`、外れたら `0` に戻す。

- `ALWAYS_ON_GATEWAYS` に含まれる: AC 電源の有無を問わず抑止 (在席中に AC を抜き差ししながら使うオフィス等)
- `KNOWN_GATEWAYS` に含まれる: AC 電源に接続中のときだけ抑止 (自宅等、蓋閉じ = 持ち出しの合図になりやすい場所)

30 秒間隔で評価するので、電源を抜いた直後やネットワークを移った直後に自動で復帰する。

両方の設定が空、または設定ファイルそのものが無い場合はどのネットワークも既知と見なさず、抑止は一度も有効にならない。設定漏れが抑止の垂れ流しにならない側へ倒してある。

## 設定をリポジトリに置かない理由

許可するゲートウェイ MAC は `/usr/local/etc/clamshell-guard.conf` に書き、リポジトリには空のひな形 (`clamshell-guard.conf.example`) だけを置く。

ルーターの LAN 側 MAC は無線側の BSSID と近い値を取る。BSSID は公開の位置情報データベースに緯度経度付きで収録されているため、MAC を public リポジトリに載せると設置場所の推定材料になる。OUI からは機種も割れる。

## SSID を使わない理由

macOS 15 以降、SSID と BSSID の取得には位置情報の TCC 権限が要る。権限のないプロセスからはこう見える。

```
BSSID : <redacted>
SSID  : <redacted>
```

root の LaunchDaemon に位置情報権限は与えられないため、SSID ベースの判定は成立しない。ゲートウェイの MAC アドレスなら ARP テーブルから権限なしで読めるうえ、同名 SSID の別ネットワークとも取り違えない。

## VPN 下での注意

デフォルトルートは VPN 接続中に `utun*` へ向くため、`route -n get default` から引くとトンネルの終端を掴んでしまう。DHCP が配った router オプションを使えば物理ネットワークを正しく識別できる。

```sh
ipconfig getoption en0 router   # 192.168.1.1
```

## 導入

```sh
sudo ./install.sh
```

初回は `/usr/local/etc/clamshell-guard.conf` がひな形から作られる。値が空なので、この時点ではまだ何も抑止しない (install.sh もその旨を警告する)。続けて許可するネットワークを登録する。

## ネットワークの登録

対象ネットワークに接続した状態でゲートウェイの MAC を調べる。

```sh
arp -n "$(ipconfig getoption en0 router)"
```

得られた MAC を設定ファイルの `KNOWN_GATEWAYS` (AC 接続時のみ抑止) または `ALWAYS_ON_GATEWAYS` (AC の有無を問わず抑止) に空白区切りで書く。大文字小文字と先頭ゼロの有無は読み込み側で揃えるため、`arp` の出力をそのまま貼ってよい。

```sh
sudo vi /usr/local/etc/clamshell-guard.conf
```

設定はデーモンが毎回読み直すため、書き換えたら 30 秒以内に反映される。`install.sh` の再実行は要らない (スクリプト本体を変えたときだけ入れ直す)。

## 取り外し

```sh
sudo ./uninstall.sh
```

`disablesleep` は 0 に戻される。設定ファイルは実機側の資産なので消さずに残る。

## ログ

```sh
tail -f /var/log/clamshell-guard.log
```

状態が変わったときだけ記録する。

## 動作確認

`pmset` を叩かずに判定結果だけを見る。

```sh
sudo CLAMSHELL_GUARD_DRY_RUN=1 ./clamshell-guard.sh
```

現在値と目標が一致するときは何も出力しない (冪等なので `pmset` を呼ばない)。無出力を故障と読み違えないよう、判断の前に下の `plutil` で実値を確かめる。

別の設定ファイルで試すなら `CLAMSHELL_GUARD_CONFIG` で差し替える。

```sh
sudo CLAMSHELL_GUARD_DRY_RUN=1 CLAMSHELL_GUARD_CONFIG=./clamshell-guard.conf.example ./clamshell-guard.sh
```

現在の設定値の確認。

```sh
plutil -p /Library/Preferences/com.apple.PowerManagement.plist
```
