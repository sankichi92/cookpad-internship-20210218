# 投票（Poll）と票（Vote）

ここからテスト駆動開発 （Test-Driven Development: TDD） で投票機能を開発していきます。

TDD の基本は、次のサイクルを回して開発を進めることです。

1. レッド: 動作しないテストを1つ書く
2. グリーン: 最小限の実装でとにかくテストを通す
3. リファクタリング: ちゃんとした実装にする

まずは一度、やってみましょう。

## Poll クラスの作成

TODO リストの先頭から着手します。

> - [ ] 投票 (Poll) はタイトルと複数の候補を持つ

### レッド: 動作しないテストを1つ書く

はじめにテストを書きます。
`spec/poll_spec.rb` を開いて以下を書いてください。

```ruby
RSpec.describe Poll do
  it 'has a title and candidates' do
    poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
  end
end
```

ここで、テストライブラリ [RSpec](http://rspec.info/) を簡単に説明します。

最初の

```ruby
RSpec.describe Poll do
  # ...
end
```

はブロック内に記述するテストの対象が `Poll` クラスであることを宣言しています。

次の

```ruby
it 'has a title and candidates' do
  # ...
end
```

はそれ (`Poll`) に期待する振る舞いを宣言しています。ここでは「タイトルと複数の候補を持つ」をそのまま英語にしています（クックパッド社内の慣習に従って英語で書いていますが、ただの文字列なので日本語でも構いません）。

そして、宣言した内容に対応するテストコードを `it` メソッドのブロックの中に書きます。

```ruby
poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])

expect(poll.title).to eq 'Awesome Poll'
expect(poll.candidates).to eq ['Alice', 'Bob']
```

ここで、

```ruby
expect(foo).to eq bar
```

は `foo` と `bar` が等しい（`foo == bar` が true を返す）かどうかをテストするコードです。 `foo` では実際の呼び出しの結果が参照されるようにします。また、`bar` には結果として期待する内容を記述します。
等しければテストが成功し、そうでなければテストが失敗します。

では、一度テストを実行してみましょう。

    $ bundle exec rspec

以下のような「赤色」の出力が得られるはずです。

```
An error occurred while loading ./spec/poll_spec.rb.
Failure/Error:
  RSpec.describe Poll do
    it 'has a title and candidates' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
  
      expect(poll.title).to eq 'Awesome Poll'
      expect(poll.candidates).to eq ['Alice', 'Bob']
    end
  end

NameError:
  uninitialized constant Poll
# ./spec/poll_spec.rb:1:in `<top (required)>'
No examples found.


Finished in 0.00002 seconds (files took 0.0648 seconds to load)
0 examples, 0 failures, 1 error occurred outside of examples
```

これで最初のステップ「レッド: 動作しないテストを1つ書く」は完了です！

### グリーン: 最小限の実装でとにかくテストを通す

TDD では、テストが失敗して初めて実装に入ります。

先ほどのテスト失敗の出力を見ると、`Poll` クラスが定義されていないためにエラーになっていました。

```
NameError:
  uninitialized constant Poll
```

このステップでは**とにかくテストを通す**ことが目的なので、まずはこのエラーをなくすため `Poll` を定義します。

ファイル `lib/poll.rb` を開き、`Poll` クラスを定義してください。

```ruby
class Poll
end
```

そして、`spec/poll_spec.rb` の先頭で `Poll` を定義したファイルを読み込んでください。

```diff
+require_relative '../lib/poll'
+
 RSpec.describe Poll do
   it 'has a title and candidates' do
     poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])

```

テストを実行します。

    $ bundle exec rspec

すると、まだテストは失敗しますが、エラーの内容が変わります。

```
F

Failures:

  1) Poll has a title and candidates
     Failure/Error: poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
     
     ArgumentError:
       wrong number of arguments (given 2, expected 0)
     # ./spec/poll_spec.rb:5:in `initialize'
     # ./spec/poll_spec.rb:5:in `new'
     # ./spec/poll_spec.rb:5:in `block (2 levels) in <top (required)>'

Finished in 0.00468 seconds (files took 0.11718 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/poll_spec.rb:4 # Poll has a title and candidates
```

`Poll.new` の引数の数がちがうことにより `ArgumentError` になっているので、コンストラクタを定義します。
今出ているエラーをなくすことが目的なので、中身は実装しません。

```diff
 class Poll
+  def initialize(title, candidates)
+  end
 end

```

テストを実行します。

    $ bundle exec rspec

```
     NoMethodError:
       undefined method `title' for #<Poll:0x00007ffe8f246a40>
```

今度はメソッド `title` が定義されていないためエラーになっているので定義します。中身は実装しません。

```diff
 class Poll
   def initialize(title, candidates)
   end
+
+  def title
+  end
 end
```

テストを実行します。

    $ bundle exec rspec

```
     Failure/Error: expect(poll.title).to eq 'Awesome Poll'
     
       expected: "Awesome Poll"
            got: nil
```

`poll.title` が `"Awesome Poll"` を返すことを期待したのに `nil` が返ってきたため、テストが失敗しました。
そこで、メソッド `title` が `"Awesome Poll"` を返すようにします。

```diff
   end
 
   def title
+    'Awesome Poll'
   end
 end
```

まぬけな実装ですが、このステップでは**最小限の実装でとにかくテストを通す**ことが目的です。

このように、テストを通すためにベタ書きの値を用いることを**仮実装**と呼びます。
仮実装により、テストが意図通りに動いていることを確認できます。
逆にいえば、仮実装でテストが失敗するときは、テストや何か別の箇所がおかしい可能性が高いです。
仮実装せずに複雑な実装をすると、実装がおかしいのかテストがおかしいのかわからなくなってしまいます。

テストを実行すると、今度はメソッド `candidates` が定義されていないというエラーが出るので、同様にメソッド `candidates` を仮実装してください。

<details>
<summary> メソッド <code>candidates</code> の仮実装</summary>

```diff
   def title
     'Awesome Poll'
   end
+
+  def candidates
+    ['Alice', 'Bob']
+  end
 end
```
</details>

仮実装ができたら、テストを実行します。

    $ bundle exec rspec

テストが通り、以下のような「緑色」の出力が得られるはずです。

```
.

Finished in 0.00542 seconds (files took 0.11174 seconds to load)
1 example, 0 failures
```

これで2番目のステップ「グリーン: どんな実装でもよいのでとにかくテストを通す」は完了です :tada:
ここで一度、コミットしておきましょう。

今回は初回なので、小まめにテストを実行して極端なやり方でエラーを1つずつ潰していきましたが、実際にここまで細かくやることはあまりありません。しかし、「とにかくテストを通す」と「最小限の実装」を目指すことで、やるべきことが明確になる TDD のメリットは体感できたのではないかと思います。

### リファクタリング: ちゃんとした実装にする

仮実装をちゃんとした実装に置き換えてください。

<details>
<summary><code>Poll</code> のリファクタリング</summary>

```ruby
class Poll
  attr_reader :title, :candidates

  def initialize(title, candidates)
    @title = title
    @candidates = candidates
  end
end
```
</details>

リファクタリングできたら、テストを実行します。

    $ bundle exec rspec

テストが失敗しなければ、リファクタリング成功です。
ここで新しくコミットするか、あるいは仮実装のコミットを上書きするなりしておきましょう。
以降は文章中でコミットを促さないので、各自で適宜コミットしてください。

最後のステップ「リファクタリング: ちゃんとした実装にする」が終わり、TODO リストの1つめが完了しました :tada:

> - [x] 投票 (Poll) はタイトルと複数の候補を持つ

## Vote クラスの作成

TODO リストの3番目の

> - [ ] 票 (Vote) は投票者の名前と候補者の名前をもつ

は1番目とよく似ています。
同じように TDD で実装してみてください。

<details>
<summary><code>spec/vote_spec.rb</code></summary>

```ruby
require_relative '../lib/vote'

RSpec.describe Vote do
  it 'has a voter and a candidate' do
    vote = Vote.new('Miyoshi', 'Alice')

    expect(vote.voter).to eq 'Miyoshi'
    expect(vote.candidate).to eq 'Alice'
  end
end
```
</details>

<details>
<summary><code>lib/vote.rb</code></summary>

```ruby
class Vote
  attr_reader :voter, :candidate

  def initialize(voter, candidate)
    @voter = voter
    @candidate = candidate
  end
end
```
</details>

失敗するテストを書き、それを通し、リファクタリングまでできれば、また1つ TODO リストをチェックします。

> - [x] 票 (Vote) は投票者の名前と候補者の名前をもつ

ここで、テスト実行時に `--format doc` のオプションを渡してみてください。

```
$ bundle exec rspec --format doc

Poll
  has a title and candidates

Vote
  has a voter and a candidate

Finished in 0.00188 seconds (files took 0.08593 seconds to load)
2 examples, 0 failures
```

`.` の代わりにRSpec の `describe` や `it` に渡した文字列が表示され、どういう振る舞いをテストしているか一覧できます。
TODO リストの仕様がすべてここに緑色で表示されるのを目指していきます。

## 練習問題1

1. 「投票にはオプションで締切日時を設定できる」という仕様が追加されたとして、TDD でこれを実装せよ。

---

[次へ](03-vote-validation.md)
