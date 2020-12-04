# 投票アプリ

ここまでで実装した投票機能を使って、以下の機能をもつウェブアプリケーションを作成します。

- `GET /`: 投票のタイトル一覧できる
- `GET /polls/:id`: 投票の詳細を確認できる
- `POST /polls/:id/votes`: 票を追加できる
- `GET /polls/:id/result`: 投票の結果を確認できる

## Sinatra について

投票アプリの開発には、軽量 Web アプリケーションフレームワーク [Sinatra](http://sinatrarb.com/) を用います。

`app.rb` を開いて、sinatra をロードしてください。

```ruby
require 'sinatra'
```

次のコマンドを叩くと HTTP Web サーバーが起動します。

    $ bundle exec ruby app.rb
    
http://localhost:4567/ にアクセスして、

> Sinatra doesn't know this ditty.

という文言とともにマイクしかない寂しいステージの画像が表されれば問題ありません。

## テストについて

また、投票アプリのテストは、時間の関係上事前に用意してあるものを用います。

`spec/app_spec.rb` の最初の行の `=begin` と最後の行の `=end` を削除してください。
Ruby は `=begin` / `=end` のあいだをコメントと同じように扱います。

```diff
-=begin
 require 'sinatra/test_helpers'
 require_relative '../app'

```
```diff
     end
   end
 end
-=end
```

削除したら、一度テストを実行してみてください。

```
$ bundle exec rspec
******.....

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) PollApp GET / responds 200 OK
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:18

  2) PollApp GET /polls/:id with valid id responds 200 OK
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:33

  3) PollApp GET /polls/:id with invalid id responds 404 Not Found
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:41

  4) PollApp POST /polls/:id/votes with valid id and params adds a vote and redirects to /polls/:id
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:57

  5) PollApp POST /polls/:id/votes with invalid id responds 404 Not Found
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:68

  6) PollApp POST /polls/:id/votes with invalid params responds 400 Bad Request
     # Temporarily skipped with xdescribe
     # ./spec/app_spec.rb:78


Finished in 0.00815 seconds (files took 0.20848 seconds to load)
11 examples, 0 failures, 6 pending
```

PollApp のテストが pending として表示されます。

---

[次へ](07-poll-list.md)
