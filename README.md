1. こちらのリポジトリを git clone します．
2. リポジトリのルートの階層 (`～/U22-procon/`) に移動します．
3. パッケージをインストールするために，コマンドラインに `flutter pub get` と入力し実行します．
4. コマンドラインに `flutter devices` と入力し実行することで，実行に選択可能なデバイスの一覧が返されます．
   1. スマホでアプリを実行させたい場合は，スマホをデバッグモードにできるように予め設定し，PC と通信可能なケーブルで接続してください．
5. 4.にて確認したデバイス名称を `{device_name}` とすると，コマンドラインに `flutter run -v -d {device_name}` と入力し実行することで，指定したデバイスにてアプリが起動します．（ここで，`-v` は verbose であり，なくても OK です）

## 3. 開発方針 <a id="3"></a>

- 当該リポジトリは issue ドリブン開発を用いて開発を進めていきます．
  - branch の派生について，まずは issue を登録し，main から分岐させてください．
  - issue 作成の際には template を用いてください．
  - branch の名称は，`{branch_name}/#{issue_num}_{todo}` とすることを推奨します．
    - `{branch_name}` : `add`, `fix`, `update` など
    - `{issue_num}` : issue 番号
    - `{todo}` : やることを英語で記載（例： `add_readme` など）
  - commit メッセージは `[{branch_name}] #{issue_num} {done}` とすることを推奨します．
    - `{branch_name}` : `add`, `fix`, `update` など
    - `{issue_num}` : issue 番号
    - `{done}` : やったことを日本語で要約して記載
  - `{branch_name}`は下記のようにします.足りないのがあれば教えて下さい.
    - 機能追加 add:
    - 機能修正 update:
    - バグ修正 fix:
    - 削除 remove:
    - 仕様の変更 change:
    - 整理 clean:
  - pull request 作成の際にも template を用いますが，github 上から選択できないので，`./.github/PULL_REQUEST_TEMPLATE/feature.md` の中身をコピーし作成してください．
- 基本的にはアジャイル開発チックに進めていきましょう．
  - 機能考えつくして一気に開発していくという流れではなく，色々作って試行錯誤的に完成させていくという流れです．
  - 資料よりもコードを書いたり実装しましょう．
