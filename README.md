# Cookpad 1 Day Internship 2021-02-18

Cookpad 1 Day Internship へのご参加ありがとうございます！

当日はプログラミング言語 Ruby を使ってハンズオンを行います。
ハンズオンを円滑に進めるため、開発環境の準備と前提知識の確認をお願いします。

## 開発環境の準備: Ruby と Git のインストール

Ruby と Git を使用できる環境の準備をお願いします。
環境がすでにある場合は、動作確認に進んでください。
ない場合は、使用している OS ごとに以下の手順でインストールしてください（その他の OS の場合は https://www.ruby-lang.org/en/documentation/installation/ を参照してください）。

### macOS

[Homebrew](https://brew.sh) をインストール後、次のコマンドで Ruby と Git をインストールします。

    $ brew install ruby git

### Windows

[Windows Subsystem for Linux](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10) で Ubuntu をインストールしてください。
その後、次のコマンドで必要なパッケージをインストールします。

    $ sudo apt update && sudo apt install ruby ruby-dev git build-essential

### 動作確認

以下のコマンドを1つずつ実行して、最後に `0 failures` と表示されれば動作確認は完了です。

```
$ git clone https://github.com/sankichi92/cookpad-internship-20210218.git
$ cd cookpad-internship-20210218
$ gem install bundler
$ bundle install
$ bundle exec rspec devenv_spec.rb
.

Finished in 0.0053 seconds (files took 0.09453 seconds to load)
1 example, 0 failures
```

もしいずれかのコマンドが失敗した場合は、事前に Slack でお知らせください。

## 前提知識の確認: Ruby と Git の基本

Ruby と Git について、以下のページにある内容は前提知識として扱います。
馴染みがない場合は、目を通しておいてください。

- 20分ではじめるRuby https://www.ruby-lang.org/ja/documentation/quickstart/
- Git Handbook (10 minutes read) https://guides.github.com/introduction/git-handbook/
