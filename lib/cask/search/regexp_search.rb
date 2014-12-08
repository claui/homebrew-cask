class Cask::Search::RegexpSearch < Cask::Search::Delegate
  def self.using_regexp?
    true
  end

  def exact_match?(cask)
    false
  end

  def partial_match?(cask)
    partial_match_pattern === context.value_from(cask)
  end

  private

  def search_term
    @search_term ||= search_terms.first
  end

  def search_regexp
    @search_regexp ||= self.class.extract_regexp(search_term)
  end

  def partial_match_pattern
    @partial_match_pattern = /#{search_regexp}/i
  end
end
