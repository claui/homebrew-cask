class Cask::Search::LiteralSearch < Cask::Search::Delegate
  def self.using_regexp?
    false
  end

  def exact_match?(cask)
    exact_match_pattern === to_simplified_string(cask)
  end

  def partial_match?(cask)
    partial_match_pattern === to_simplified_string(cask)
  end

  private

  def search_term
    @search_term ||= search_terms.join(' ')
  end

  def exact_match_pattern
    @exact_match_pattern = /^#{simplified_search_term}$/i
  end

  def partial_match_pattern
    @partial_match_pattern = /#{simplified_search_term}/i
  end

  def simplified_search_term
    Cask::QualifiedToken::simplified_search_term(search_term)
  end

  def to_simplified_string(cask)
    target_string = context.value_from(cask)
    Cask::QualifiedToken::simplified_search_term(target_string)
  end
end
