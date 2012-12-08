#!/Users/chr/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

require "./collapsible_group_helper"

include CollapsibleGroupHelper

g = collapsible_group :t => 2  do
  set :id => "f1"
  item :title => "item1", :for => 1
  item :title => "item2", :body => "TTTT"
  group :id => "g2" do
    item :title => "item10" 
    group :id => "g3" do
      item :title => "item17" do 
        set :title do
           "item17---"
        end
        set :body => "meinbody" 
      end
    end
  end
  item :title => "item3"
  item do 
    set :title => "item4"
  end
  group :id => "g4" do
    item :title => "item5" 
    group :id => "g5" do
      item :title => "item7",  :body => "Test"
      group :id => "g6" do
        item :title => "item8" do
          set :body => "SDSDS"
        end
      end
    end
  end
end
