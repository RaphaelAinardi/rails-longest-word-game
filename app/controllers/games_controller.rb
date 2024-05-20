require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    alphabet = ("a".."z").to_a
    @letters = alphabet.sample(10)
  end

  def score
    @letters = params[:letters].split('')
    @attempt = params[:attempt]

    if valid_word?(@attempt, @letters)
      if english_word?(@attempt)
        @score = calculate_score(@attempt)
        @message = "Bien joué ! '#{@attempt}' est un mot anglais valide. Votre score est de #{@score}."
      else
        @score = 0
        @message = "Désolé, mais '#{@attempt}' n'est pas un mot anglais valide."
      end
    else
      @score = 0
      @message = "Désolé, le mot #{@attempt} ne peut pas être formé à partir des lettres #{@letters.join(', ')}."
    end
  end

  private

  def valid_word?(attempt, letters)
    attempt.chars.all? { |char| attempt.count(char) <= letters.count(char) }
  end

  def english_word?(word)
    url = "https://api.dictionaryapi.dev/api/v2/entries/en/#{word}"
    begin
      response = URI.open(url).read
      json_response = JSON.parse(response)
      json_response.is_a?(Array) && json_response.first['word'].casecmp?(word)
    rescue OpenURI::HTTPError => e
      false
    end
  end

  def letter_score(letter)
    scores = {
      "a" => 1, "b" => 3, "c" => 3, "d" => 2, "e" => 1, "f" => 4, "g" => 2, "h" => 4,
      "i" => 1, "j" => 8, "k" => 5, "l" => 1, "m" => 3, "n" => 1, "o" => 1, "p" => 3,
      "q" => 10, "r" => 1, "s" => 1, "t" => 1, "u" => 1, "v" => 4, "w" => 4, "x" => 8,
      "y" => 4, "z" => 10
    }
    scores[letter.downcase] || 0
  end

  def calculate_score(word)
    score = 0
    word.chars.each do |char|
      score += letter_score(char)
    end
    score
  end
end
