class Term
  attr_accessor :info

  def initialize(info:)
    self.info = info
  end
end

class TmTrue < Term
end

class TmFalse < Term
end

class TmIf < Term
  attr_accessor :t1, :t2, :t3

  def initialize(t1:, t2:, t3:, **params)
    super(**params)

    self.t1 = t1
    self.t2 = t2
    self.t3 = t3
  end
end

class TmZero < Term
end

class TmSucc < Term
  attr_accessor :t1

  def initialize(t1:, **params)
    super(**params)
    self.t1 = t1
  end
end

class TmPred < Term
  attr_accessor :t1

  def initialize(t1:, **params)
    super(**params)
    self.t1 = t1
  end
end

class TmIsZero < Term
  attr_accessor :t1

  def initialize(t1:, **params)
    super(**params)
    self.t1 = t1
  end
end

class NoRuleApplies < StandardError
end
