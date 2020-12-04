# 票の追加

このページからはじめる場合は、ブランチ `09-post-vote` を用いてください。

    $ git switch 09-post-vote

手元にコミットしていない変更が残っている場合は、コミットするか下記のコマンドで変更を退避させるかしてから switch しましょう。

    $ git stash -u

---

以下を実装していきます。

> - `POST /polls/:id/votes`: 票を追加できる

投票詳細をブラウザで閲覧したとき、次の HTML で表現されるフォームがありました。

```erb
<form action="/polls/<%= index %>/votes" method="post">
  <label for="voter">あなたの名前</label>
  <input id="voter" name="voter" type="text">

  <label for="candidate">投票する候補名</label>
  <input id="candidate" name="candidate" type="text">

  <input type="submit" value="投票する">
</form>
```

このフォームを入力して「投票する」ボタンを押すと、次のような HTTP リクエストが送信されます（説明のため簡略化しています）。

```http
POST /polls/1/votes HTTP/1.1
Host: localhost:4567
Content-Type: application/x-www-form-urlencoded

voter=foo&candidate=bar
```

`curl` で送信するには、次のようにします。

```shell
$ curl http://localhost:4567/polls/1/votes -X POST -d "voter=foo&candidate=bar"
```

このリクエストを受け取ったとき、フォームの入力内容をもとに投票を追加するようにします。

`spec/app_spec.rb` を開いて、`POST /polls/:id/votes` のテストを探し、スキップしないようにしてください。

```diff
     end
   end
 
-  xdescribe 'POST /polls/:id/votes' do
+  describe 'POST /polls/:id/votes' do
     let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }
 
     before do
```

これらのテストが通るようにルーティング `POST /polls/:id/votes` を実装してください。

POST など、いくつか説明していない項目がありますが、以下のドキュメント等を参考に、調べながら実装してみましょう。

- Sinatra http://sinatrarb.com/intro-ja.html
- Ruby https://www.ruby-lang.org/ja/documentation/
- HTTP https://developer.mozilla.org/ja/docs/Web/HTTP

<details>
<summary><code>POST /polls/:id/votes</code> の実装</summary>

```diff
 
   erb :poll, locals: { index: index, poll: poll }
 end
+
+post '/polls/:id/votes' do
+  index = params['id'].to_i
+  poll = $polls[index]
+  halt 404 if poll.nil?
+
+  vote = Vote.new(params['voter'], params['candidate'])
+  poll.add_vote(vote)
+
+  redirect to("/polls/#{index}"), 303
+rescue Poll::InvalidCandidateError
+  halt 400, '不正な候補名です'
+end
```
</details>

## 投票結果の表示

以下を実装してください。

> - `GET /polls/:id/result`: 投票の結果を確認できる

投票結果ページについては、テストも ERB のテンプレートもありません。
既存のコードを参考に実装してみましょう。

実装できたら、投票アプリは完成です :tada:
以下の練習問題や[発展課題](advanced.md)に進んでください。

## 練習問題3

1. 現状の新規投票フォームは任意の候補名を入力できる。HTML の `select` 要素を使って選択式にせよ。
2. フォームから投票 (poll) を追加できるようにせよ。
3. （練習問題1-1、2-1で実装した）締切日時が投票に設定されていて、その日時を過ぎていた場合、適切なエラーを返すようにせよ。

---

[発展課題へ](advanced.md)
