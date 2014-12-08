require 'test_helper'

describe Cask::CLI::Search do
  it "finds Casks that have no actual `name`" do
    out, err = capture_io do
      Cask::CLI::Search.run('noactualname')
    end
    out.must_match(/no-actual-name/)
    out.length.must_be :<, 100
  end

  it "does not search for the word `name` out of context" do
    out, err = capture_io do
      Cask::CLI::Search.run('barprofessional')
    end
    out.must_match(/^No Cask found for "barprofessional"\.\n/)
  end

  describe "multiple Casks with the same token in different taps" do
    describe "when the search term exactly matches the token" do
      it "does not include the name in brackets" do
        out, err = capture_io do
          Cask::CLI::Search.run('firefox')
        end
        (out =~ /Duplicate/).must_be_nil
      end
    end

    describe "when the search term partially matches the token" do
      it "does not include the name in brackets" do
        out, err = capture_io do
          Cask::CLI::Search.run('fire')
        end
        (out =~ /Duplicate/).must_be_nil
      end
    end
  end
end
