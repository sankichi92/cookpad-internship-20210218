# 投票一覧

このページからはじめる場合は、ブランチ `07-poll-list` を用いてください。

    $ git switch 07-poll-list

手元にコミットしていない変更が残っている場合は、コミットするか下記のコマンドで変更を退避させるかしてから switch しましょう。

    $ git stash -u

---

以下を実装していきます。

> - `GET /`: 投票のタイトル一覧できる

## HTTP とウェブアプリケーション

実装に入る前に、`GET /` とはなんでしょう？
これは、HTTP のリクエストを表しています。

ブラウザのアドレスバーに `http://localhost:4567/` を入力してエンターを押すと、ブラウザは入力された URL を解釈して、次のようなメッセージを含む HTTP リクエストを送信します。

```http
GET / HTTP/1.1
Host: localhost:4567
```

1行目の先頭が `GET /` になっています。[`GET`](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/GET) は HTTP のリクエストメソッド、`/` はパス、`HTTP/1.1` はプロトコルのバージョン、2行目から空行まではヘッダーです。

サーバーサイドで動くウェブアプリケーションは、このような HTTP リクエストに対してレスポンスを返します。

`curl` コマンドで、現状のレスポンスを確認してみましょう。

```shell
$ curl http://localhost:4567/ -i
```

レスポンスの1行目が

```http
HTTP/1.1 404 Not Found
```

のようになっているはずです。
[`404`](https://developer.mozilla.org/ja/docs/Web/HTTP/Status/404) は HTTP のステータスコードで、`Not Found` はステータスメッセージです。
これは、リクエストしたリソースをサーバーが見つけられなかったことを表しています。

HTTP についてより詳しくは https://developer.mozilla.org/ja/docs/Web/HTTP 等を参照してください。

では、 `GET /` のリクエストに対して、投票一覧を返すよう実装していきましょう。

## `GET /` の実装

### ステータスコード 200 を返す

`spec/app_spec.rb` を開いて、`GET /` のテストを探し、`xdescribe` から先頭の `x` を消してください。
ブロック内のテストが skip されなくなります。

```diff
     $polls = []
   end
 
-  xdescribe 'GET /' do
+  describe 'GET /' do
     it 'responds 200 OK' do
       get '/'
 
```

テストを実行します。

    $ bundle exec rspec

`GET /` のレスポンスに [`200`](https://developer.mozilla.org/ja/docs/Web/HTTP/Status/200) を期待したところ、`404` が返ってきたためテストが失敗しました。

```
  1) PollApp GET / responds 200 OK
     Failure/Error: expect(last_response.status).to eq 200
     
       expected: 200
            got: 404
```

`app.rb` を開いて `GET /` に対して 200 を返すようにします。

```diff
 require 'sinatra'
+
+get '/' do
+  [200, {}, '投票一覧']
+end
```

ここで、Sinatra について簡単に説明します。

```ruby
get '/' do
  # ...
end
```

は、ルーティングを定義します。
HTTP メソッドとパスのパターンがペアになっており、この場合 `GET /` にマッチします。
マッチしたときブロックが実行されます。

また、ブロックの返り値を元に HTTP レスポンスが決まります。
`[200, {}, '投票一覧']` のように3要素の配列を返した場合、1つめの要素がステータスコード、2つめの要素がヘッダー、3つめの要素がボディになります（この仕様は [Rack](https://github.com/rack/rack) に由来します）。

サーバーを再起動して、ブラウザや `curl` で確認してみましょう。

```
$ bundle exec ruby app.rb
（別のウィンドウへ移動）
$ curl http://localhost:4567 -i
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Content-Length: 12
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Server: WEBrick/1.6.0 (Ruby/2.7.2/2020-10-01)
Date: Sun, 6 Dec 2020 00:00:00 GMT
Connection: Keep-Alive

投票一覧
```

テストが通ることも確認します。

    $ bundle exec rspec

また、200 と空のヘッダーは省略できます。

```diff
 require 'sinatra'
 
 get '/' do
-  [200, {}, '投票一覧']
+  '投票一覧'
 end
```

### ボディに投票一覧を含める

200 は返りましたが、ブラウザで開くとまだ「投票一覧」という文字列が表示されるだけです。
Poll のインスタンスの配列をつくって、そのタイトル一覧を表示するようにします。

```diff
 require 'sinatra'
+require_relative 'lib/poll'
+require_relative 'lib/vote'
+
 get '/' do
-  '投票一覧'
+  polls = [
+    Poll.new('好きな料理', ['肉じゃが', 'しょうが焼き', 'から揚げ']),
+    Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
+  ]
+  erb :index, locals: { polls: polls }
 end
```

ここで、

```ruby
erb :index, locals: { polls: polls }
```

は、`views/index.erb` をレンダリングします。
[ERB](https://rubyapi.org/2.7/o/erb) は Ruby のテンプレートシステムで、文書中に Ruby のコードを埋め込むことができます。`views/index.erb` を見ると、`polls` のタイトルのリストを HTML で表現しています。オプション `locals` は、テンプレート中で変数 `polls` を使えるようにするためのものです。

```erb
<h1>投票一覧</h1>
<ul>
  <% polls.each_with_index do |poll, i| %>
    <li><a href="/polls/<%= i %>"><%= poll.title %></a></li>
  <% end %>
</ul>
```

また、`views/layout.erb` が存在する場合は、デフォルトでこれをレイアウトとして使用するようになっています。

今回、`views` は事前に用意してあるので、HTML について詳しく説明しません。詳しく知りたい場合は https://developer.mozilla.org/ja/docs/Web/HTML 等を参照してください。

サーバーを再起動して、ブラウザで投票のタイトル一覧が表示されることを確認してみましょう。

    $ bundle exec ruby app.rb

これで投票一覧は完成です :tada:

---

[次へ](08-poll-detail.md)
