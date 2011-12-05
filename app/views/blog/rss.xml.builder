
@title = @blog.title + " by " + @blog.user.description
@preferred_stylesheet = @blog.style.stylesheet
posts = Post.find(:all)

posts = Post.find(:all,
                  :conditions => ["blog_id = ? AND is_viewable = 't'", @blog.id],
                  :order => "updated_at DESC",
                  :limit => @blog.posts_per_page,
                  :offset => @offset)




xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title h(@blog.title)
    #TODO: make this not hard coded
    xml.description h(@blog.title)
    xml.lastBuildDate @blog.updated_at.to_s :rfc822
    
    for post in posts
      xml.item do
        xml.title h(post.subject)
        xml.description h(post.text).sub("\n", "<br />")
        xml.pubDate post.created_at.to_s(:rfc822)
      end
    end
  end
end
