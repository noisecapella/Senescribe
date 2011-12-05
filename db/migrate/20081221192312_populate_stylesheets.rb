class PopulateStylesheets < ActiveRecord::Migration
  def self.up
    Style.delete_all

    Style.create(:stylesheet => "default",
                 :css => "b { color: green; }",
                 :name => "default")
    Style.create(:stylesheet => "gzwot",
                 :css => "",
                 :name => "gzwot")
  end

  def self.down
    Style.delete_all
  end
end
