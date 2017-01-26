require "./moviedata.rb"
# movie_data = MovieData.new("ml-100k")
movie_data = MovieData.new('ml-100k', :u1)
movie_data.load
movie_test = movie_data.run_test(30)
puts "================"
puts movie_test.mean
puts "================"
puts movie_test.stddev
puts "================"
puts movie_test.rms
puts "================"
print  movie_test.to_a
puts "================"
