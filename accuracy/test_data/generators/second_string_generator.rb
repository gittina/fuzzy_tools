require 'set'
require 'uri'
require File.expand_path('../accuracy_test_generator', __FILE__)

# in the following paper, they used the whole line (key and all) and tokenized by word, so we'll use the whole line
# A comparison of string distance metrics for name-matching tasks, by W. W Cohen, P. Ravikumar, S. E Fienberg. In Proceedings of the IJCAI-2003 Workshop on Information Integration on the Web (IIWeb-03), 2003.

class SecondStringGenerator < AccuracyTestGenerator
  # key is usually the second column

  class Parser
    SOURCES_DIRECTORY = AccuracyTestGenerator::SOURCES_DIRECTORY + "/secondstring/ss"

    def string_lines
      @string_lines ||= File.read(self.class::FILE).lines.map(&:chomp)
    end
  end

  class Animal < Parser
    FILE = SOURCES_DIRECTORY + "/animal.txt"

    class Line < Struct.new(:str)
      def key_tokens
        @key_tokens ||= str.split("\t")[1].split
      end
    end

    def lines
      @lines ||= string_lines.map { |l| Animal::Line.new(l) }
    end

    # from the README:
    # there is no key for these relations - instead, a match is considered
    # correct if the tokens in either scientific name are a proper
    # subset of the other.
    def string_matches
      # tokens are words
      @string_matches ||= begin
        matches = []
        # do in blocks of at least 1 shared token
        key_tokens_to_lines.each do |key_token, lines|
          matches += lines.combination(2).select do |line1, line2|
            (line1.key_tokens - line2.key_tokens) == [] || (line2.key_tokens - line1.key_tokens) == []
          end
        end
        matches.map { |pair| pair.map(&:str).sort }.uniq
      end
    end

    def key_tokens_to_lines
      @key_tokens_to_lines ||= {}.tap do |key_tokens_to_lines|
        lines.each do |line|
          line.key_tokens.each do |key_token|
            key_tokens_to_lines[key_token] ||= []
            key_tokens_to_lines[key_token]  << line
            key_tokens_to_lines[key_token].uniq!
          end
        end
      end
    end
  end

  class Column2KeyedParser < Parser
    def key_normalizer(key)
      key.strip
    end

    def string_matches
      @string_matches ||= begin
        matches = []
        string_lines.group_by { |l| key_normalizer(l.split("\t")[1]) }.map do |key, lines|
          matches += lines.combination(2).to_a
        end
        matches.map { |pair| pair.sort }.uniq
      end
    end
  end

  class BirdKunkel < Column2KeyedParser
    # from the README: keys are URLs
    FILE = SOURCES_DIRECTORY + "/birdKunkel.txt"
  end

  class BirdNybirdExtracted < Column2KeyedParser
    # from the README: keys are scientific names.
    FILE = SOURCES_DIRECTORY + "/birdNybirdExtracted.txt"
  end

  class BirdScott1 < Column2KeyedParser
    # from the README: keys are URLS
    FILE = SOURCES_DIRECTORY + "/birdScott1.txt"
  end

  class BirdScott2 < Column2KeyedParser
    # from the README: keys are URLS
    FILE = SOURCES_DIRECTORY + "/birdScott2.txt"
  end

  class Business < Column2KeyedParser
    # from the README: keys are top-level URLs.
    # roughly 10-15% of the URLs don't match when they should.
    FILE = SOURCES_DIRECTORY + "/business.txt"

    def key_normalizer(key)
      URI.parse(key.gsub(/["\+]/,'').strip).host.gsub(/www\.?/, '')
    end
  end

  class CensusText < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/censusText.txt"
  end

  class CensusTextSegmented < Column2KeyedParser
    # has tabs intead of lots of spaces between census data columns
    FILE = SOURCES_DIRECTORY + "/censusTextSegmented.txt"
  end

  class GameExtracted < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/gameExtracted.txt"
  end

  class Parks < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/parks.txt"
  end

  class UCDPeopleCluster < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/ucdPeopleCluster.txt"
  end

  class UCDPeopleMatch < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/ucdPeopleMatch.txt"
  end

  class VaUniv < Column2KeyedParser
    FILE = SOURCES_DIRECTORY + "/vaUniv.txt"
  end

  def generate
    [
      [SecondStringGenerator::Animal,              "animal",                true],
      [SecondStringGenerator::BirdKunkel,          "bird_kunkel",           false],
      [SecondStringGenerator::BirdNybirdExtracted, "bird_nybird_extracted", true],
      [SecondStringGenerator::BirdScott1,          "bird_scott1",           false],
      [SecondStringGenerator::BirdScott2,          "bird_scott2",           true],
      [SecondStringGenerator::Business,            "business",              false],
      [SecondStringGenerator::CensusText,          "census_text",           true],
      [SecondStringGenerator::CensusTextSegmented, "census_text_segmented", true],
      [SecondStringGenerator::GameExtracted,       "game_extracted",        true],
      [SecondStringGenerator::Parks,               "parks",                 true],
      [SecondStringGenerator::UCDPeopleCluster,    "ucd_people_cluster",    true],
      [SecondStringGenerator::UCDPeopleMatch,      "ucd_people_match",      true],
      [SecondStringGenerator::VaUniv,              "va_univ",               false],
    ].each do |klass, data_set_name, include_leftovers|
      write_csv("second_string_#{data_set_name}.csv") do |csv|
        parser = klass.new
        queries, targets = Set.new, Set.new
        grouped = parser.string_matches.group_by(&:first).each do |target, match_pairs|
          matches = match_pairs.map(&:last) - [target] - queries.to_a
          if !queries.include?(target) && matches.size > 0
            csv << [target, matches.join("|")]
            queries += matches
            targets << target
          end
        end
        if include_leftovers # if the test scores go down with leftovers, we add them!!
          leftovers = parser.string_lines.uniq - queries.to_a - targets.to_a
          leftovers.each do |line|
            csv << [line, ""]
          end
        end
      end
    end
  end
end