class GamesController < ApplicationController
  def new
    @letters = generate_grid
  end

  def score
    @word = params[:word]
    @reference = params[:letters]
    @result = if !real_word?(@word)
                "Sorry, but #{@word.upcase} is not an English word."
              elsif !same_letters?(@word, @reference) || !same_count?(@word, @reference)
                "Sorry, but #{@word.upcase} cannot be built from #{@reference.chars.join(', ')}"
              else
                "Congrats! You've built a valid English word!"
              end
  end

  private

  require 'open-uri'
  require 'json'

  def generate_grid
    letters = ('A'..'Z').to_a
    grid = []
    10.times { grid << letters[rand(0..letters.size - 1)] }
    grid
  end

  def real_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    serialized = URI.open(url).read
    deserialized = JSON.parse(serialized)
    deserialized['error'] ? false : true
  end

  def convert(input)
    result = {}
    input.downcase.chars.each do |letter|
      result.key?(letter) ? result[letter] += 1 : result[letter] = 1
    end
    result
  end

  def same_letters?(word, reference)
    word = convert(word)
    reference = convert(reference)
    word.each { |key, _| return false unless reference.key?(key) }
    true
  end

  def same_count?(word, reference)
    word = convert(word)
    reference = convert(reference)
    word.each { |key, _| return false if word[key] > reference[key] }
    true
  end
end
