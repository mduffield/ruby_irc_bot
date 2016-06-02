require "rubygems"
require "net/irc"
require "pp"
require "engtagger"

class SimpleClient < Net::IRC::Client
  def initialize(*args)
    super
  end

  def on_rpl_welcome(m)
    post JOIN, "#bullpen"
    post JOIN, "#main"
  end

  def on_privmsg(m)
    maybe_replace(m[0], m[1])
    if /steve/i.match(m[1]) 
      post NOTICE, m[0], replace_phrases(m[1])
      post NOTICE, m[0], get_random_phrase
    end
  end

  def on_join(m)
    puts m[1]
    post NOTICE, m[0], get_random_phrase
  end

  def maybe_replace(channel, message)
    if rand(1..100) < 3 
      post NOTICE, channel, replace_phrases(message)
    end
  end

  def replace_phrases(message)
    tgr = EngTagger.new
    tagged = tgr.add_tags(message)
    phrases = tgr.get_noun_phrases(tagged)
    replaced = false
    phrases.each do |phrase, count|
      message.gsub!(phrase, get_random_word)
      replaced = true
    end
    if replaced 
      message
    else 
      get_random_phrase 
    end
  end

  def get_random_word
    File.readlines("words.txt").sample.strip
  end

  def get_random_phrase
    "#{random_subject} #{random_verb} #{get_random_word} #{random_filler} #{get_random_word}"
  end

  def random_filler
    File.readlines("filler.txt").sample.strip
  end

  def random_subject
    if rand(1..100) > 50 
      File.readlines("subjects.txt").sample.strip
    end
  end
  
  def random_verb
    File.readlines("verbs.txt").sample.strip
  end

end

SimpleClient.new("localhost", "6667", {
  :nick => "steve",
  :user => "steve",
  :real => "steve",
}).start
