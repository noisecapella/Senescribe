class PopulateStylesheets < ActiveRecord::Migration
  def change
    Style.delete_all

    Style.create(:stylesheet => "default",
                 :css => "b { color: green; }",
                 :name => "default")
    Style.create(:stylesheet => "gzwot",
                 :css => "",
                 :name => "gzwot")
  end
end
