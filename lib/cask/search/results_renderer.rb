class Cask::Search::ResultsRenderer
  def self.render!(results)
    if results.empty?
      puts "No Cask found for \"#{results.search_term}\"."
      return
    end

    results.format_conflicting_tokens!

    if results.exact?
      ohai "Exact match"
      puts results.exact_match.formatted_token
    end

    render_partial_matches!(results) if results.partial?
  end

  def self.render_partial_matches!(results)
    if results.using_regexp?
      ohai "Regexp matches"
    else
      ohai "Partial matches"
    end

    matches = results.partial_matches
    formatted_matches = matches.sort_by(&:token).map(&:formatted_token)
    puts_columns formatted_matches
  end
end
