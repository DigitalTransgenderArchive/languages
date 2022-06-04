# frozen_string_literal: true

require 'test_helper'

class TestLanguages < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Languages::VERSION
  end

  ::Languages::TYPES.each do |type|
    define_method "test_it_provides_scope_for_type_#{type}" do
      languages = ::Languages.public_send(type)

      assert_kind_of Enumerable, languages
      assert_instance_of ::Languages::Language, languages.first
    end
  end

  ::Languages::SCOPES.each do |scope|
    define_method "test_it_provides_scope_for_scope_#{scope}" do
      method_name = "#{scope}_language" unless scope.end_with? 'language'
      languages = ::Languages.public_send("#{method_name || scope}s")

      assert_kind_of Enumerable, languages
      assert_instance_of ::Languages::Language, languages.first
    end
  end

  def test_all_alpha2_codes_have_string_length_2
    assert(::Languages.all.map(&:alpha2).compact.all? { |a| a.size == 2 })
  end

  def test_all_alpha3_codes_have_string_length_3
    assert(::Languages.all.map(&:alpha3).compact.all? { |a| a.size == 3 })
  end

  def test_all_languages_have_a_type
    refute(::Languages.all.map(&:type).any?(&:nil?))
  end

  def test_all_languages_have_a_scope
    refute(::Languages.all.map(&:scope).any?(&:nil?))
  end

  %i[iso639_1 iso639_2b iso639_2t iso639_3 name].each do |attr|
    define_method "test_attribute_#{attr}_is_unique" do
      assert_nil(::Languages.all.map(&:"#{attr}").compact.tally.detect { |_, c| c > 1 })
    end
  end

  def test_search_provides_enumerable
    assert_kind_of Enumerable, ::Languages.search('Japanese')
  end

  def test_search_with_string_pattern
    pattern = 'Japanese'
    search_result = ::Languages.search(pattern)

    assert(search_result.map(&:name).all? { |n| n.match?(pattern) })
    refute((Languages.all - search_result).map(&:name).any? { |n| n.match?(pattern) })
  end

  def test_search_with_regex_pattern
    pattern = /\AG[ea]/
    search_result = ::Languages.search(pattern)

    assert(search_result.map(&:name).all? { |n| n.match?(pattern) })
    refute((Languages.all - search_result).map(&:name).any? { |n| n.match?(pattern) })
  end
end
