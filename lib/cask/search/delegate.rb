class Cask::Search::Delegate
  attr_accessor :exact_match
  attr_reader :partial_matches, :search_terms, :targets, :context

  def self.extract_regexp(string)
    if %r{^/(.*)/$}.match(string) then
      $1
    else
      false
    end
  end

  def self.exclude_fonts?
    !using_regexp?
  end

  def initialize(search_terms, targets, context)
    @search_terms = search_terms
    @targets = targets
    @context = context
    @partial_matches = []
  end

  def exclude_fonts!
    # suppressing search of the font Tap is a quick hack until behavior can be made configurable
    targets.reject! do |cask|
      %r{^caskroom/homebrew-fonts/}.match(cask.qualified_token)
    end
  end

  def find_exact_match!
    matching_casks = targets.select(&method(:exact_match?))
    if matching_casks.empty?
      @exact_match = nil
    else
      cask = matching_casks.first
      @exact_match = Cask::Search::Match.exact(cask, context)
    end
  end

  def find_partial_matches!
    matching_casks = targets.select(&method(:partial_match?))
    new_matches = matching_casks.map do |cask|
      Cask::Search::Match.partial(cask, context)
    end
    partial_matches.concat(new_matches).delete(exact_match)
  end

  def results
    Cask::Search::Results.new(exact_match, partial_matches,
      search_term, :using_regexp => self.class.using_regexp?)
  end
end
