class Genre < ActiveRecord::Base
  set_table_name "genre"
  has_and_belongs_to_many :movies, :join_table => "genrelinkmovie", :foreign_key => "idGenre", :association_foreign_key => "idMovie"
  
  def name
    xmbc_mapping(:strGenre)
  end
  
  def xmbc_mapping(col)
    send(col)
  end
  
end
