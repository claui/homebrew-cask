require 'delegate'

class Cask::Search::Match < SimpleDelegator
  attr_accessor :formatted_token
  attr_reader :cask, :context, :exact

  def self.exact(cask, context)
    self.new(cask, context, true)
  end

  def self.partial(cask, context)
    self.new(cask, context, false)
  end

  def initialize(cask, context, exact)
    super(cask)
    @cask = cask
    @context = context
    @exact = !!exact
  end

  def ==(other)
    return false unless other
    qualified_token == other.qualified_token
  end

  alias :eql? :==

  def hash
    qualified_token.hash
  end

  def value
    context.value_from(cask)
  end

  def to_s_a
  end

  def to_s
    a = []
    a << (formatted_token || token)
    a << "(#{ value })" unless token == value
    a.join(' ')
  end
end
