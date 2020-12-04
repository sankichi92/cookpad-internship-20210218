# 投票詳細

このページからはじめる場合は、ブランチ `08-poll-detail` を用いてください。

    $ git switch 08-poll-detail

手元にコミットしていない変更が残っている場合は、コミットするか下記のコマンドで変更を退避させるかしてから switch しましょう。

    $ git stash -u

## `sinatra/reloader`

実装に入る前に、便利なツールを導入します。`app.rb` に以下の1行を加えてください。

```diff
 require 'sinatra'
+require 'sinatra/reloader' if development?
 require_relative 'lib/poll'
 require_relative 'lib/vote'
```

これにより、サーバーを再起動しなくとも、コードの変更が自動的に反映されるようになります。
この変更を反映するためにサーバーを再起動してください（いま起動しているサーバーは `sinatra/reloader` をロードしていないので）。

    $ bundle exec ruby app.rb

以降は、コードを変更するたびにサーバーを再起動する必要はありません。

## `GET /polls/:id` の実装

以下を実装していきます。

> - `GET /polls/:id`: 投票の詳細を確認できる

ルーティングの `:id` はパラメータで、`/polls/0` や `polls/1` といったパスにマッチします。
では、`/polls/0` がリクエストされたとき、どの投票詳細返せばよいのでしょうか。

実は、投票一覧 `views/index.erb` は次のようになっています。

```erb
<% polls.each_with_index do |poll, i| %>
  <li><a href="/polls/<%= i %>"><%= poll.title %></a></li>
<% end %>
```

`polls` の配列の index を `/polls/:id` の `:id` パラメータにしてリンクしています。これに合わせて、ここでは `GET /` で用いた配列の `:id` 番目の投票詳細を返すようにします。

### 投票詳細を返す

`spec/app_spec.rb` を開いて、`GET /polls/:id` のテストを探し、`xdescribe` から先頭の `x` を消してください。

```diff
     end
   end
 
-  xdescribe 'GET /polls/:id' do
+  describe 'GET /polls/:id' do
     let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }
 
     before do
```

テストを実行します。

    $ bundle exec rspec

```
       expected: 200
            got: 404
```

前回と同じですね。`app.rb` を開いてルーティングを定義します。パラメータ `:id` は、`params` ハッシュで取得できます。

```diff
   ]
   erb :index, locals: { polls: polls }
 end
+
+get '/polls/:id' do
+  index = params['id'].to_i
+  poll = polls[index]
+
+  erb :poll, locals: { index: index, poll: poll }
+end
```

どうなるか予想しながら、テストを実行してください。

    $ bundle exec rspec

```
     NameError:
       undefined local variable or method `polls' for #<Sinatra::Application:0x00007f9bb7a5ef88>
       Did you mean?  poll
```

`get '/'` のブロックで定義した `polls` とはスコープが異なるため、`get '/polls/:id'`  のブロックからアクセスできません。その結果、`NameError` になってしまいました。

`get '/polls/:id'`（とテスト）から投票の配列にアクセスできるようにするため、`polls` をグローバル変数として定義し直します。

```diff
 require_relative 'lib/poll'
 require_relative 'lib/vote'
 
+$polls = [
+  Poll.new('好きな料理', ['肉じゃが', 'しょうが焼き', 'から揚げ']),
+  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
+]
+
 get '/' do
```

**[WARNING]** 今回は簡易化のために用いていますが、アプリケーションのデータの保存先にグローバル変数を使用することは原則として避けてください。
グローバル変数の値はプログラムを終了すると揮発してしまいます。
また、グローバル変数に書き込みを行う場合、マルチスレッドで意図しない結果になることがあります。
データの保存先の置き換えは、[発展課題](advanced.md) で扱います。

`get '/'` と `get '/polls/:id'` で `$polls` を使うように書き換えてください。

<details>
<summary>グローバル変数への置き換え</summary>

```diff
 ]
 
 get '/' do
-  polls = [
-    Poll.new('好きな料理', ['肉じゃが', 'しょうが焼き', 'から揚げ']),
-    Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
-  ]
-  erb :index, locals: { polls: polls }
+  erb :index, locals: { polls: $polls }
 end
 
 get '/polls/:id' do
   index = params['id'].to_i
-  poll = polls[index]
+  poll = $polls[index]
 
   erb :poll, locals: { index: index, poll: poll }
 end
```
</details>

ブラウザで http://localhost:4567/polls/0 にアクセスして、投票詳細が表示されることを確認してください。

### 投票が見つからなかったとき

ここで、テストを実行してみましょう。

    $ bundle exec rspec

「不正な ID のとき 404 Not Found を返す」というテストが失敗するはずです。

```
  1) PollApp GET /polls/:id with invalid id responds 404 Not Found
     Failure/Error: get '/polls/1'
     
     NoMethodError:
       undefined method `title' for nil:NilClass
```

実際、http://localhost:4567/polls/100 のようなページにアクセスするとエラー画面が表示されます。

これは、パラメータ `:id` が配列の範囲外の値のため `$polls[index]` が `nil` を返し、`views/poll.erb` で `poll.title` を評価したとき `nil` に対して `title` メソッドを呼んでしまうことになるためです。

`:id` が配列の範囲外の場合は、404 を返すようにします。

```diff
 get '/polls/:id' do
   index = params['id'].to_i
   poll = $polls[index]
+  halt 404, '投票が見つかりませんでした' if poll.nil?
 
   erb :poll, locals: { index: index, poll: poll }
 end
```

`halt` を使うことで、ルーティング内でただちにリクエストを止めることができます。

テストを実行してすべて通ることを確認してください。

    $ bundle exec rspec

ブラウザや `curl` でも 404 Not Found が返ることを確認してみましょう。

```shell
$ curl http://localhost:4567/polls/100 -i
```

```http
HTTP/1.1 404 Not Found
Content-Type: text/html;charset=utf-8
Content-Length: 39
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Server: WEBrick/1.6.0 (Ruby/2.7.2/2020-10-01)
Date: Sun, 06 Dec 2020 00:00:00 GMT
Connection: Keep-Alive

投票が見つかりませんでした
```

これで投票詳細は完成です :tada:

---

[次へ](09-post-vote.md)
