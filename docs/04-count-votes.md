# 集計

このページからはじめる場合は、ブランチ `04-count-votes` を用いてください。

    $ git switch 04-count-votes

手元にコミットしていない変更が残っている場合は、コミットするか下記のコマンドで変更を退避させるかしてから switch しましょう。

    $ git stash -u

---

最後の TODO に着手します。

> - [ ] 票を集計することができ、集計結果は候補の名前とそれぞれの獲得票数の一覧で表現される

`Poll` に票を集計するメソッド `#count_votes` を追加し、キーが candidate、値が票数の連想配列（Hash）を返すようにします。

```ruby
{
  'Alice' => 2,
  'Bob' => 1,
}
```

## レッド

まずは、`spec/poll_spec.rb` にテストを書きます。

```diff
       end
     end
   end
+
+  describe '#count_votes' do
+    it 'counts the votes and returns the result as a hash' do
+      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
+      poll.add_vote(Vote.new('Carol', 'Alice'))
+      poll.add_vote(Vote.new('Dave', 'Alice'))
+      poll.add_vote(Vote.new('Ellen', 'Bob'))
+
+      result = poll.count_votes
+
+      expect(result['Alice']).to eq 2
+      expect(result['Bob']).to eq 1
+    end
+  end
 end
```

書いたテストが `NoMethodError` で失敗することを確認します。

    $ bundle exec rspec

## グリーン

### 仮実装

テストが通るように仮実装してください。

<details>
<summary><code>Poll#count_votes</code> の仮実装</summary>

```diff
 
     @votes.push(vote)
   end
+
+  def count_votes
+    {
+      'Alice' => 2,
+      'Bob' => 1,
+    }
+  end
 end
```
</details>

仮実装できたら、テストが通ることを確認します。

    $ bundle exec rspec

### 三角測量

テストが通ったら、本来はリファクタリングに入ります。
しかし、今回は正しい実装までの道筋が必ずしも自明ではありません（少なくとも私はそうです）。
そんなときは、**三角測量**を行います。

三角測量では、もう1つテストを追加します。

```diff
       expect(result['Alice']).to eq 2
       expect(result['Bob']).to eq 1
       expect(result.keys).to eq ['Alice', 'Bob']
+
+      poll2 = Poll.new('Great Poll', ['Alice', 'Bob'])
+      poll2.add_vote(Vote.new('Carol', 'Bob'))
+      poll2.add_vote(Vote.new('Dave', 'Bob'))
+
+      result2 = poll2.count_votes
+
+      expect(result2['Alice']).to eq 0
+      expect(result2['Bob']).to eq 2
     end
   end
 end
```

テストが失敗することを確認してください。

```
$ bundle exec rspec
...F.

Failures:

  1) Poll#count_votes counts the votes and sorts the candidates by the number of votes
     Failure/Error: expect(result2['Alice']).to eq 0
     
       expected: 0
            got: 2
     
       (compared using ==)
     # ./spec/poll_spec.rb:50:in `block (3 levels) in <top (required)>'

Finished in 0.03521 seconds (files took 0.08035 seconds to load)
5 examples, 1 failure

Failed examples:

rspec ./spec/poll_spec.rb:33 # Poll#count_votes counts the votes and sorts the candidates by the number of votes
```

1点から見ただけではある目標物までの距離が測れなくとも、2点からであれば三角法を使って目標物までの距離を算出できます。
これを利用して測量するがもともとの三角測量ですが、TDD の三角測量では2つのテストを書くことで、1つのテストでは見えなかった実装のゴールを明確にします。ここでのゴールは、2つのテストが通る一般化された実装です。テストが2つあることで、実装を一般化する必要が生じます。

テストが通るように `Poll#count_votes` を実装してください。

実装できたら、テストが通ることを確認してください。

    $ bundle exec rspec

## リファクタリング

テストが通ったらリファクタリングです。
すでに一般化は済んでいるので、読みやすさやパフォーマンスが改善できないかもう一度コードを見直してください。

リファクタリングできたら、最後にもう一度テストが通ることを確認します。

```
$ bundle exec rspec --format doc

Poll
  has a title and candidates
  #add_vote
    saves the given vote
    with a vote that has an invalid candidate
      raises InvalidCandidateError
  #count_votes
    counts the votes and sorts the candidates by the number of votes

Vote
  has a voter and a candidate

Finished in 0.00491 seconds (files took 0.08562 seconds to load)
5 examples, 0 failures
```

そして、最後の TODO にチェックします。

> - [x] 票を集計することができ、集計結果は候補の名前とそれぞれの獲得票数の対で表現される。また、その順序は票数の降順である

以上で、投票機能は完成です :tada:

---

[次へ](05-tdd-summary.md)
