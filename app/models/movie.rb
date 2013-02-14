class Movie < ActiveRecord::Base
  set_table_name "movie"
  belongs_to :file, :foreign_key => "idFile", :class_name => Mediafile.name
  has_one :path, :through => :file
  has_one :settings, :through => :file
  has_many :details, :through => :file
  has_and_belongs_to_many :genres, :join_table => "genrelinkmovie", :foreign_key => "idMovie", :association_foreign_key => "idGenre"
  
  has_many :tags, :as => :tagable, :dependent => :delete_all
  has_many :labels, :through => :tags
  
  scope :order_by_rating, :order => "c05 DESC"
  scope :order_by_title, :order => "c00 ASC"
  scope :order_by_id, :order => "idMovie DESC"
  
  scope :stacked, :conditions => ["files.strFilename like ?","stack://%"], :include => :file
  
  scope :by_genre,   ->(genres)   {{:conditions =>["genrelinkmovie.idGenre in (?)",genres], :include => :genres}}
  scope :by_title,   ->(title)    {{:conditions =>["c00 like ?","%#{title}%"]}}
  scope :by_plot,    ->(word)     {{:conditions =>["c01 like ?","%#{word}%"]}}
  scope :by_imdbid,  ->(imdbid)   {{:conditions =>["c09 = ?",imdbid]}}
  
  scope :by_label,      lambda { |label|   {:conditions =>["labels.id in (?)",label],:include => [:labels]}}
  scope :by_label_key,  lambda { |label|   {:conditions =>["labels.key in (?)",label],:include => [:labels]}}
  
  
  scope :localtitle_matches_topdirectory, ->(year) {{:conditions =>["path.strPath like ? AND path.strPath like CONCAT(?,c00,?)", "%/#{year}/%",'%/','/%'], :include => [:file => :path]}}
  
  soundex_columns [:c00]
  
  paginates_per 100
  
  # c08: Alternative Cover
  # c13: Top 250
  # c18: Studio
  # c19: Trailer
  # c20: Alternative Fanart
  
  
  def localtitle
    xmbc_mapping(:c00)
  end
  
  def plot
    xmbc_mapping(:c01)
  end

  def tagline
    xmbc_mapping(:c03)
  end

  def votes
    xmbc_mapping(:c04)
  end

  def rating
    xmbc_mapping(:c05)
  end

  def author
    xmbc_mapping(:c06)
  end

  def year
    xmbc_mapping(:c07)
  end
  
  def imdbid
    xmbc_mapping(:c09)
  end

  def runtime
    xmbc_mapping(:c11)
  end

  def director
    xmbc_mapping(:c15)
  end

  def originaltitle
    xmbc_mapping(:c16)
  end

  def studio
    xmbc_mapping(:c18)
  end

  def country
    xmbc_mapping(:c21)
  end
  
  def cover
    parse_html(xmbc_mapping(:c08)).inject([]){|r,i| r << i.attributes['preview'] if i.name == "thumb"; r}
  end

  def fanart
    parse_html(xmbc_mapping(:c20)).inject([]){|r,i| r << i.attributes['preview'] if i.name == "thumb"; r}
  end
  
  
  def self.reorganize_directories(year)
    Movie.localtitle_matches_topdirectory(year).map{|m| m.file.path}.uniq.each do |path| 
      printf "%130s -> %s (%d) %sp %s\n", path.strPath, 
                                          path.topdirectory, 
                                          path.files.first.movie.year,  
                                          path.files.first.details.map{|d| d.video_resolution}.join(""),
                                          path.files.first.details.map{|d| d.strVideoCodec}.join("").upcase
    end
  end
  
  private
  
  def parse_html(html)
    tokens = HTML::Tokenizer.new(html)
    tags = []
    while token = tokens.next
      node = HTML::Node.parse(nil, 0, 0, token, false)
      tags << node if node.tag? and node.closing != :close
    end
    tags
  end
  
  def xmbc_mapping(col)
    send(col)
  end
  
  
  
    
end