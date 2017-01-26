require "./movietest.rb"

class MovieData
  def initialize(str,filename = nil)
    @users = Hash.new
    @movies = Hash.new
    if(filename == nil)
      @filepath = str + "/u.data"
      @testpath = nil
    else
      @filepath = "./" + str + "/#{filename.to_s}.base"
      @testpath = "./" + str + "/#{filename.to_s}.test"
    end
  end

  def load
    content = open(@filepath)
    content.each do |line|
      user_id, movie_id, rating = line.split("\t")
      if @users.has_key?(user_id)
        @users[user_id][movie_id] = rating
      else
        @users[user_id] = Hash.new
        @users[user_id][movie_id] = rating
      end

      if @movies.has_key?(movie_id)
        @movies[movie_id][user_id] = rating
      else
        @movies[movie_id] = Hash.new
        @movies[movie_id][user_id] = rating
      end
    end
  end

  def rating(user_id, movie_id)
    return @users[user_id][movie_id]
  end

  def predict(user_id, movie_id)
    sorted_similar_id = most_similar(user_id)
    sorted_similar_id.each do |key|
      if(@movies[movie_id][key] != nil)
        return @movies[movie_id][key]
      end
    end
  end

  def movies(user_id)
    return @users[user_id]
  end

  def viewers(movie_id)
    return @users[movie_id]
  end

  def similarity(user1,user2)
    rating1 = @users[user1]
    rating2 = @users[user2]
    vector1, vector2 = Array.new
    inner_product = 0
    (1..1682).each do |index|
      if(rating1.has_key?(index.to_s) && rating2.has_key?(index.to_s))
         inner_product += rating1[index.to_s].to_i * rating2[index.to_s].to_i
       end
    end

    norm1 = norm2 = 0
    rating1.each_value do |dim|
      norm1 += (dim.to_i * dim.to_i)
    end

    rating2.each_value do |dim|
      norm2 +=  (dim.to_i * dim.to_i)
    end
    return inner_product /((norm1 ** (1.0 / 2)) * (norm1 ** (1.0 / 2)))
  end

  def most_similar(u)
    similarities = Hash.new
    @users.each_key do |user_id|
      similarities[user_id] = similarity(u,user_id)
    end

    list = Array.new
    similarities.sort{|a,b|b[1]<=>a[1]}.each{|item| list.push(item[0])}
    return list
  end

  def run_test(k = nil)
    if @testpath == nil
      return nil
    end

    tests = open(@testpath)
    if k == nil
      k = tests.length
    end

    errors =  Array.new
    predictions = Array.new
    sum = 0
    rms = 0

    count = 0
    tests.each do |line|
      if count == k
        break
      end

      user_id, movie_id, rating = line.split("\t")

      if @movies[movie_id] == nil || @users[user_id] == nil
        continue
      end

      predict_result = predict(user_id, movie_id)
      puts predict_result,rating
      error = (predict_result.to_i - rating.to_i).abs
      sum = sum + error
      rms = rms + error ** 2
      predictions.push([user_id, movie_id, rating, predict_result])
      errors.push(error)
      count = count + 1
    end

    rms = (rms / errors.length) ** 0.5
    mean = sum / errors.length

    std = 0
    errors.each do |error|
      std = std + (error - mean) ** 2
    end

    std = (std / errors.length) ** 0.5
    return movie_test = MovieTest.new(mean, std, rms, predictions)
  end
end
