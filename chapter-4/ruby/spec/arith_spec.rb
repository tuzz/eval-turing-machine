RSpec.describe "Arith" do
  include Arith

  let(:_) { :dont_care }

  let(:zero) { TmZero.new(info: _) }
  let(:succ1) { TmSucc.new(info: _, t1: zero) }
  let(:succ2) { TmSucc.new(info: _, t1: succ1) }
  let(:succ3) { TmSucc.new(info: _, t1: succ2) }
  let(:tru) { TmTrue.new(info: _) }
  let(:fals) { TmFalse.new(info: _) }

  describe "#isnumericval" do
    specify do
      expect(isnumericval(zero)).to eq(true)
      expect(isnumericval(succ1)).to eq(true)
      expect(isnumericval(succ2)).to eq(true)
      expect(isnumericval(succ3)).to eq(true)
    end

    specify do
      succ = TmSucc.new(info: _, t1: tru)

      expect(isnumericval(tru)).to eq(false)
      expect(isnumericval(succ)).to eq(false)
    end
  end

  describe "#isval" do
    specify do
      expect(isval(tru)).to eq(true)
      expect(isval(fals)).to eq(true)
      expect(isval(zero)).to eq(true)
      expect(isval(succ2)).to eq(true)
    end

    specify do
      succ = TmSucc.new(info: _, t1: tru)
      expect(isval(succ)).to eq(false)

      iszero = TmIsZero.new(info: _, t1: zero)
      expect(isval(iszero)).to eq(false)
    end
  end

  describe "#eval1" do
    let(:t1) { TmIf.new(info: _, t1: tru, t2: :foo, t3: :bar) }

    specify do
      term = TmIf.new(info: _, t1: tru, t2: :t2, t3: :t3)
      expect(eval1(term)).to eq(:t2)

      term = TmIf.new(info: _, t1: fals, t2: :t2, t3: :t3)
      expect(eval1(term)).to eq(:t3)

      term = TmIf.new(info: _, t1: t1, t2: :t2, t3: :t3)
      result = eval1(term)
      expect(result).to be_a(TmIf)
      expect(result.info).to eq(t1.info)
      expect(result.t1).to eq(:foo)
      expect(result.t2).to eq(:t2)
      expect(result.t3).to eq(:t3)

      term = TmSucc.new(info: _, t1: t1)
      result = eval1(term)
      expect(result).to be_a(TmSucc)
      expect(result.info).to eq(t1.info)
      expect(result.t1).to eq(:foo)

      term = TmPred.new(info: _, t1: zero)
      result = eval1(term)
      expect(result).to be_a(TmZero)
      expect(result.info).to eq(:dummyinfo)

      term = TmPred.new(info: _, t1: succ1)
      expect(eval1(term)).to eq(zero)

      term = TmPred.new(info: _, t1: t1)
      result = eval1(term)
      expect(result).to be_a(TmPred)
      expect(result.info).to eq(term.info)
      expect(result.t1).to eq(:foo)

      term = TmIsZero.new(info: _, t1: zero)
      result = eval1(term)
      expect(result).to be_a(TmTrue)
      expect(result.info).to eq(:dummyinfo)

      term = TmIsZero.new(info: _, t1: succ1)
      result = eval1(term)
      expect(result).to be_a(TmFalse)
      expect(result.info).to eq(:dummyinfo)

      term = TmIsZero.new(info: _, t1: t1)
      result = eval1(term)
      expect(result).to be_a(TmIsZero)
      expect(result.t1).to eq(:foo)
    end

    specify do
      expect { eval1(tru) }.to raise_error(NoRuleApplies)
      expect { eval1(fals) }.to raise_error(NoRuleApplies)
      expect { eval1(zero) }.to raise_error(NoRuleApplies)

      term = TmIf.new(info: _, t1: zero, t2: :t2, t3: :t2)
      expect { eval1(term) }.to raise_error(NoRuleApplies)

      term = TmIsZero.new(info: _, t1: tru)
      expect { eval1(term) }.to raise_error(NoRuleApplies)

      term = TmIsZero.new(info: _, t1: fals)
      expect { eval1(term) }.to raise_error(NoRuleApplies)

      term = TmSucc.new(info: _, t1: zero)
      expect { eval1(term) }.to raise_error(NoRuleApplies)
    end
  end

  describe "#evaluate" do
    specify do
      # (if
      #   (iszero (if true zero (succ zero)))
      #   (tmpred (succ (succ zero)))
      #   (succ false)
      # )
      term = TmIf.new(
        info: _,
        t1: TmIsZero.new(
          info: _,
          t1: TmIf.new(
            info: _,
            t1: TmTrue.new(info: _),
            t2: TmZero.new(info: _),
            t3: TmSucc.new(
              info: _,
              t1: TmZero.new(info: _),
            ),
          ),
        ),
        t2: TmPred.new(
          info: _,
          t1: TmSucc.new(
            info: _,
            t1: TmSucc.new(
              info: _,
              t1: TmZero.new(info: _),
            ),
          ),
        ),
        t3: TmSucc.new(
          info: _,
          t1: TmFalse.new(info: _),
        ),
      )

      result = evaluate(term)
      expect(result).to be_a(TmSucc)
      expect(result.t1).to be_a(TmZero)
    end

    specify do
      term = TmSucc.new(
        info: _,
        t1: TmSucc.new(
          info: _,
          t1: TmSucc.new(
            info: _,
            t1: TmTrue.new(info: _),
          ),
        ),
      )

      result = evaluate(term)
      expect(result).to eq(term), "Should be unable to evaluate anything."
    end
  end
end
