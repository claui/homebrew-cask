cask :v1test => 'no-actual-name' do
  version :latest
  sha256 :no_check

  url TestHelper.local_binary_url('caffeine.zip')
  homepage 'http://example.com/local-caffeine'
  license :oss

  app 'Bar Professional.app'

  caveats do
    <<-EOS.undent
      I wish this cask had a proper
      name 'Bar Professional'
    EOS
  end
end
