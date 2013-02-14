class AjaxController < ApplicationController
  
  def imdbverify
    if params[:id]
      imdbvalid = (params[:status] == "valid") ? true : false
      @movie = Movie.find(params[:id]) 
      if imdbvalid != @movie.imdbvalid? || imdbvalid == @movie.imdbinvalid?
        @movie.labels = [Label.find_by_key(imdbvalid ? 'imdbvalid' : 'imdbinvalid')]
        @movie.save
      end
    end
  end
    
      
  def moviedetails
    @movie = Movie.find(params[:id]) if params[:id]
  end
  
  def autocomplete_titlesearch
    render json: (Movie.by_title(params[:title]).map do |o|
      Hash[ id: o.id, name: o.localtitle]
    end)
  end
  
  def autocomplete_plotsearch
    render json: (Movie.by_plot(params[:plot]).map do |o|
      plot  = fulltextsearch(params[:plot], o.plot, 10)       
      Hash[ name: params[:plot], text: "#{o.localtitle}: #{plot}"]
    end)
  end
  
  
  private
  
    # find query in text, and present result in a shortened form
    def fulltextsearch(query, text, words=2)
      result = ""
      if text =~ /.*#{query}.*/i
        text_words = text.scan(/\w*/)
        indexes = []
        text_words.each_with_index do |word,index|
          if word =~ /.*#{query}.*/i
            i = []
            i << index - words unless words == 0 || index - words < 0
            i << index
            i << index + words unless words == 0 || index + words > text_words.length
            indexes << i
          end
        end
        indexes.each do |i|
          result += "... " unless i.length == 1
          i.each {|j| result += "#{text_words[j]} "}
          result += " ..." unless i.length == 1
        end
      end
      result
    end
    
  
end