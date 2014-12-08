class Cask::CLI::Base
  def self.command_name
    @command_name ||= self.name.sub(%r{^.*:}, '').gsub(%r{(.)([A-Z])}, '\1_\2').downcase
  end

  def self.visible
    true
  end

  def self.remove_options(args)
    args.reject { |a| a.chars.first == '-' }
  end

  # This method is deprecated.
  # It has been renamed to `remove_options` because the command line
  # can contain search terms that refer to other fields than
  # just cask tokens.
  def self.cask_tokens_from(args)
    remove_options(args)
  end

  def self.help
    "No help available for the #{command_name} command"
  end
end
