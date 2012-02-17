class Shared

  def self.get_errors(model, error_list)
    #convert validation errors into a string
    message = ""
    
    #error_list = error_list.reject { |error| !model.errors.invalid?(error) }
    errors = error_list.map { |error| "%s is missing" % error.to_s }
    
    
    if errors.length != 0
      message = ": " + errors.join(", ")
    end
    return message
  end

  protected
  def self.age_formula(age_index, num_words, num_ages)
    #change this if you want to make the distribution of colors
    #logarithmic or split distributed across time, instead of distributed
    #equally across each age bracket
    ((age_index / num_ages.to_f) * num_words).floor.to_i
  end

  public
  def self.calculate_aged_text(post, text)
    #return a marked-up piece of text with older words marked differently
    #than newer words

    #this is already sorted by creation date
    word_by_creation = post.serialized_words.map {|each| Word.from_array(each) }

    return "" if word_by_creation.length == 0

    oldest_time = word_by_creation.first.created_at
    youngest_time = word_by_creation.last.created_at
    
    #from oldest to youngest
    ages = ["age1", "age2", "age3", "age4", "age5", "age6", "age7",
            "age8", "age9", "age10", "age11", "age12", "age13", "age14",
            "age15", "age16", "age17", "age18", "age19", "age20", "age21",
            "age22", "age23", "age24", "age25", "age26"]

    replacements = []
    previous_boundary = 0
    boundaries = []

    #make a set of age brackets
    ages.length.times do |age_index| 
      s = age_formula(age_index, word_by_creation.length, ages.length)
      e = age_formula(age_index + 1, word_by_creation.length, ages.length)
      if age_index == ages.length - 1
        boundaries <<= word_by_creation[s].created_at..word_by_creation[-1].created_at
      else
        boundaries <<= word_by_creation[s].created_at...word_by_creation[e].created_at
      end
    end
    

    starting_age_index = 0
    replacements = post.serialized_words.map {|array| Word.from_array(array) }.map do |word|
      #this is technically O(n) but it should rarely do more than one iteration
      #since the words are sorted by age already, we know that once
      #we pass an age, we can ignore it afterward
      age_index = boundaries.index { |each| each.cover? word.created_at }
      if age_index != 0
        boundaries = boundaries[age_index..-1]
        starting_age_index += age_index
        age_index = 0
      end
      
      ret = "<span class='" + ages[starting_age_index] + "'>" 
      ending = word.current_position + word.word.length
      ret += text[word.current_position...ending] || ""
      ret += "</span>"

      #a replacement as an array
      [word.current_position, word.current_position + word.word.length, ret]
    end


    replacements.sort.reverse.each do |replacement|
      text[replacement[0]...replacement[1]] = replacement[2]
    end
   
    text
  end
  


protected
  def self.choose_closest_word(new_words, word)
    #choose the word with the smallest differences of index
    min = nil
    min_word = new_words[0]
    new_words.each do |new_word| 
      v = (new_word.current_index - word.current_index).abs
      if min.nil? or v < min
        min_word = new_word
        min = v
      end
    end
    return min_word
  end



  def self.split_into_words(text, post)
    #split into words, where a word is anything surrounded by whitespace
    matchdata_array = []
    no_whitespace = /[^\s+]+/
    matchdata = text.match(no_whitespace)
    
    while !matchdata.nil?
      matchdata_array <<= matchdata
      matchdata = matchdata.post_match.match(no_whitespace)
    end
    
    words = Shared.add_words(matchdata_array)
    return words
  end


  class Word
    #contains basic elements of a word
    #current_index is the offset from the beginning of the post (in words)
    #current_position is the offset from the beginning of the post (in characters)
    #word is the word in text
    #created_at is the time the word was written
    attr_accessor :current_index, :current_position, :word, :created_at

    def to_array
      #convert to an array to aid in serialization
      [self.current_index, self.current_position, self.word, self.created_at]
    end

    def self.from_array(array)
      #convert from an array to aid in readability
      word = Word.new
      word.current_index, word.current_position, word.word, word.created_at = array
      word
    end

    def initialize
      self.word = ""
      self.created_at = Time.now
      self.current_position = 0
      self.current_index = 0
    end
  end
public
  def self.add_words(matchdata_array)
    #get all the words matching a regular expression
    words = []
    current_offset = 0
    current_index = 0

    matchdata_array.map do |matchdata|
      word = Word.new
      word.word = matchdata.to_s
      word.current_index = current_index
      word.current_position = current_offset + matchdata.offset(0)[0]

      words <<= word

      current_offset += matchdata.offset(0)[1]
      current_index += 1
    end
    return words
  end


public
  def self.from_array(serialized_words)
    #convert a serialized word array to an array of Word objects
    serialized_words.map { |array| Word.from_array(array) }
  end

  def self.update_word_table(processed_text, post)
    #calculate word ages, and save information in post
    previous_words = post.serialized_words.nil? ? [] : Shared.from_array(post.serialized_words)
    
    new_words = split_into_words processed_text, post

    #store words to be looked up by word
    new_words_as_hash = new_words.inject(Hash.new) do |hash, word|
      #store in an array because a word can appear twice in a post
      hash[word.word] ||= []
      hash[word.word] <<= word
      hash
    end
    

    save_these_words = []

    for word in previous_words
      new_words = new_words_as_hash[word.word]
      if !new_words.nil? and new_words.length != 0
        #word didn't change, update its position and index
        new_word = choose_closest_word(new_words, word)

        word.current_index = new_word.current_index
        word.current_position = new_word.current_position

        save_these_words <<= word
        
        #we're going to add in the unaccounted words later, this one is accounted for
        new_words.delete new_word
        if new_words.length == 0
          new_words_as_hash.delete word.word
        end
      end
    end
    
    #unaccounted new words
    
    new_words_as_hash.each do |name, list| 
      list.each do |word|
        #word added
        save_these_words <<= word
      end
    end

    post.serialized_words = save_these_words.sort { |a,b| a.created_at <=> b.created_at }.map { |word| word.to_array }
    post.save
    
  end
end
