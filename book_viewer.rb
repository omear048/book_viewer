require "sinatra"                   #Requires the rack-based web development framework called sinatra
require "sinatra/reloader"          #Causes the application to reload it's files each time we load the page
require "tilt/erubis"

before do 
  @contents = File.readlines("data/toc.txt")          #Loads the contents of the toc.txt file which contains the names of all the chapters # We add the .readlines method to translate each of the lines in the toc.txt field into an array of chapter names 
end                                                   #We are setting the @contents instance variable at a Global level so it doesn't have to be defined in the "/" and "/chapters/:number" sections below. This way we do not have to repea the code 

helpers do                                  #Here are the helper methods that can be defined and used at anypoint in the .rb file or .css template files
  def in_paragraphs(text)                   #This method makes the text easier to read by splitting the text into a new spaced paragraph everytime a line break is found in the array or text padded in from the .txt files    
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end
end

# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

get "/" do                                    #Is declaring a route that matches the URL "/". When a user visits that path on the application, Sinatra will execute the body of the block. The value that is returned by the block is then sent to the user's browser. 
  @title = "The Adentures of Sherlock Holmes"
 
  erb :home                                   #Loads the erb template instead of the original template.html that was originall read ==> (File.read "public/template.html")  #Loads the contents of the file "public/template.html" and sends it to the browser. This file contains the HTML code that you currently see when viewing the application in a browser. 
end

get "/chapters/:number" do                            #Declates the route that matches the URL "/". When the user visits that path on the application, Sinatra will execute the body of the block. The value that is returned by the block is then sent to the user's browser.Adding parameter to the URL pattern.Values passed to the application through the URL in this way appear in the params Hash that is autmatically made available to routes. 
  number = params[:number].to_i                       #Loading the ":number" parameter; values passed to the application through the URL in this way appear in the params Hash that is autmatically made available to routes; setting a local variable == to the parameter passed back from the URL. 
  
  chapter_name = @contents[number - 1]                #-1 is required because the correct index within the @contents array is the chapter - 1 

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")      #Reads the content found in chp1.txt allowing us to pass it into the erb template that is loaded

  erb :chapter                                        #Loads the chapter template allowing all of the instance variables defined above to be passed in 
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

get "/show/:name" do 
  params[:name]
end

not_found do 
  redirect "/"
end
