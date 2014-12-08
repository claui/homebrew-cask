class Cask::Search::Results
  attr_reader :exact_match, :search_term, :partial_matches, :options

  def initialize(exact_match, partial_matches, search_term, options = {})
    @exact_match = exact_match
    @partial_matches = partial_matches || []
    @search_term = search_term
    @options = options
  end

  def length
    matches.length
  end

  def matches
    [exact_match].compact.concat(partial_matches)
  end

  def empty?
    !(exact? || partial?)
  end

  def exact?
    !!exact_match
  end

  def partial?
    !partial_matches.empty?
  end

  def using_regexp?
    !!options[:using_regexp]
  end

  def format_conflicting_tokens!
    Cask::QualifiedToken.generate_unique_tokens!(matches,
      :qualified_token.to_proc) do |match, unique_token|
      match.formatted_token = unique_token
    end
  end

  def merge(other)
    if exact?
      new_exact_match = exact_match
      new_partial_matches = [other.exact_match].compact
    else
      new_exact_match = other.exact_match
      new_partial_matches = []
    end
    new_partial_matches.concat(partial_matches)
    new_partial_matches.concat(other.partial_matches)
    new_partial_matches.delete(new_exact_match)

    self.class.new(new_exact_match, new_partial_matches.uniq,
      search_term, options.merge(other.options))
  end

  def to_s
    matches.map(&:to_s).join("\n")
  end
end
