module Arith
  def isnumericval(t)
    t.is_a?(TmZero) ||
    t.is_a?(TmSucc) && isnumericval(t.t1) ||
    false
  end

  def isval(t)
    t.is_a?(TmTrue) ||
    t.is_a?(TmFalse) ||
    isnumericval(t) ||
    false
  end

  def eval1(t)
    if t.is_a?(TmIf) && t.t1.is_a?(TmTrue)
      t.t2
    elsif t.is_a?(TmIf) && t.t1.is_a?(TmFalse)
      t.t3
    elsif t.is_a?(TmIf)
      t1_ = eval1(t.t1)
      TmIf.new(info: t.info, t1: t1_, t2: t.t2, t3: t.t3)
    elsif t.is_a?(TmSucc)
      t1_ = eval1(t.t1)
      TmSucc.new(info: t.info, t1: t1_)
    elsif t.is_a?(TmPred) && t.t1.is_a?(TmZero)
      TmZero.new(info: :dummyinfo)
    elsif t.is_a?(TmPred) && t.t1.is_a?(TmSucc) && isnumericval(t.t1.t1)
      t.t1.t1
    elsif t.is_a?(TmPred)
      t1_ = eval1(t.t1)
      TmPred.new(info: t.info, t1: t1_)
    elsif t.is_a?(TmIsZero) && t.t1.is_a?(TmZero)
      TmTrue.new(info: :dummyinfo)
    elsif t.is_a?(TmIsZero) && t.t1.is_a?(TmSucc) && isnumericval(t.t1.t1)
      TmFalse.new(info: :dummyinfo)
    elsif t.is_a?(TmIsZero)
      t1_ = eval1(t.t1)
      TmIsZero.new(info: t.info, t1: t1_)
    else
      raise NoRuleApplies
    end
  end

  def evaluate(t)
    t_ = eval1(t)
    evaluate(t_)
  rescue NoRuleApplies
    t
  end
end
