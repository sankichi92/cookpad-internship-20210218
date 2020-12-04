# 票の追加とバリデーション

このページからはじめる場合は、ブランチ `03-vote-validation` を用いてください。

    $ git switch 03-vote-validation

手元にコミットしていない変更が残っている場合は、コミットするか下記のコマンドで変更を退避させるかしてから switch しましょう。

    $ git stash -u

## 票の追加

TODO リストの2番目に着手します。

> - [ ] 投票に対して票を投じることができる

ここでは、`Poll` にインスタンスメソッド `#add_vote` を追加して、この仕様を実現することにします。

まず、`#add_vote` のテストを追加します。
`spec/poll_spec.rb` に以下を書いてください。

```diff
     expect(poll.title).to eq 'Awesome Poll'
     expect(poll.candidates).to eq ['Alice', 'Bob']
   end
+
+  describe '#add_vote' do
+    it 'saves the given vote' do
+      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
+      vote = Vote.new('Miyoshi', 'Alice')
+
+      poll.add_vote(vote)
+
+      expect(poll.votes).to eq [vote]
+    end
+  end
 end
```

RSpec の `describe` はネストさせることができます。

```ruby
describe '#add_vote' do
  # ...
end
```

でブロック内のテストの対象が `Poll` のインスタンスメソッド `#add_vote` であることを宣言しています。

また、上記では `poll.votes` が `[vote]` と等しいかをテストしていますが、

```ruby
expect(poll.votes).to include vote
```

と書いて `vote` を含む（`poll.votes.include?(vote)` が true を返す）かどうかをテストすることもできます。
こうした `eq` や `include` のような RSpec のメソッドを **matcher** といいます。
他にどのような matcher があるかについては https://relishapp.com/rspec/rspec-expectations/v/3-10/docs を参照してください。

では、テストが `NoMethodError` で失敗することを確認します。

    $ bundle exec rspec

テストが失敗するのを確認したところで、実装に入ります。
まずは仮実装——なんですが、実装が自明の場合はそのまま実装してしまいましょう。
これを**明白な実装**といいます。
（もちろん、明白でないなら仮実装からはじめるべきです。）

<details>
<summary><code>Poll#add_vote</code> の実装</summary>

```diff
 class Poll
-  attr_reader :title, :candidates
+  attr_reader :title, :candidates, :votes
 
   def initialize(title, candidates)
     @title = title
     @candidates = candidates
+    @votes = []
   end
+
+  def add_vote(vote)
+    @votes.push(vote)
+  end
 end
```
</details>

実装できたら、テストが通ることを確認します。

```
$ bundle exec rspec
...

Finished in 0.00465 seconds (files took 0.0765 seconds to load)
3 examples, 0 failures
```

TODO にチェックをつけます。

> - [x] 投票に対して票を投じることができる

## 票のバリデーション

TODO リストの4番目に着手します。

> - [ ] 存在しない候補の名前を持つ票を投じることはできない

存在しない候補の名前を持つ票が `#add_vote` に渡されたとき、`InvalidCandidateError` の例外を発生させるようにします。

まずは、`spec/poll_spec.rb` にテストを書きます。

```diff
 
       expect(poll.votes.last).to eq vote
     end
+
+    context 'with a vote that has an invalid candidate' do
+      it 'raises InvalidCandidateError' do
+        poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
+        vote = Vote.new('Miyoshi', 'INVALID')
+
+        expect { poll.add_vote(vote) }.to raise_error Poll::InvalidCandidateError
+      end
+    end
   end
 end
```

ここで、

```ruby
context 'with a vote that has an invalid candidate' do
  # ...
end
```

はブロック内に記述するテストの条件が「引数の票が不正な候補を持つとき」であることを宣言しています。
`describe` と同じく、`context` はテストをグループ化し、自然言語で仕様を記述するためのものです。

また、

```ruby
expect { poll.add_vote(vote) }.to raise_error Poll::InvalidCandidateError
```

は、`poll.add_vote(vote)` を実行したとき `Poll::InvalidCandidateError` が発生するかどうかをテストするコードです。
例外が発生すればテストが成功し、発生しなければテストが失敗します。
例外の発生をテストする場合は、`expect` にブロックでテスト対象を渡す必要がある点に注意してください。

では、テストを実行します。

    $ bundle exec rspec

`Poll::InvalidCandidateError` が定義されていないというエラーが出るので、定義します。

```diff
 class Poll
+  class InvalidCandidateError < StandardError
+  end
+
   attr_reader :title, :candidates, :votes
 
   def initialize(title, candidates)
```

Ruby でカスタム例外クラスを定義するときは、`StandardError` を継承させます。

続いて、例外を発生させる部分を仮実装してください。

<details>
<summary>仮実装</summary>

```diff
   end
 
   def add_vote(vote)
+    if vote.candidate == 'INVALID'
+      raise InvalidCandidateError
+    end
+
     @votes.push(vote)
   end
 end
```
</details>

仮実装できたら、すべてのテストが通ることを確認します。

    $ bundle exec rspec

確認できたらリファクタリングします。

<details>
<summary>リファクタリング</summary>

```diff
   end
 
   def add_vote(vote)
-    if vote.candidate == 'INVALID'
+    unless candidates.include?(vote.candidate)
       raise InvalidCandidateError
     end
 
```
</details>

リファクタリングできたら、再度すべてのテストが通ることを確認します。

```
$ bundle exec rspec --format doc

Poll
  has a title and candidates
  #add_vote
    saves the given vote
    with a vote that has an invalid candidate
      raises InvalidCandidateError

Vote
  has a voter and a candidate

Finished in 0.0032 seconds (files took 0.08415 seconds to load)
4 examples, 0 failures
```

TODO にチェックをつけます。

> - [x] 存在しない候補の名前を持つ票を投じることはできない

## 練習問題2

1. すでに投票済みの投票者による票を追加できないようにせよ。
2. （練習問題1-1で実装した）締切日時が投票に設定されていて、その日時を過ぎていた場合、票を追加できないようにせよ。

---

[次へ](04-count-votes.md)
