class Cask::Proxy
  attr_reader :qualified_token

  def initialize(qualified_token, &resolver)
    @qualified_token = qualified_token
    @__resolver = resolver
  end

  def token
    Cask::QualifiedToken::short_token_from(qualified_token)
  end

  def to_s
    token
  end

  def respond_to?(symbol, include_private = false)
    return true if [:qualified_token, :token, :to_s].include?(symbol)
    return false if symbol == :to_ary
    @__resolver.call.respond_to?(symbol, include_private)
  end

  def method_missing(symbol, *args)
    @__resolver.call.send(symbol, *args)
  end
end
