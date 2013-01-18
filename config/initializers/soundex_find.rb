# soundex-find from https://github.com/waltjones/soundex_find
require 'soundex_find/soundex_find'
ActiveRecord::Base.send(:include, WGJ::SoundexFind)
