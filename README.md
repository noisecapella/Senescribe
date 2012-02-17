## Senescribe (from senescene, the process of aging)
This is a project from my Ruby on Rails class back in 2008 or 2009. It's since been updated to work with Rails 3.2. 

_Note:_ AJAX calls are currently done on every keyup. I need to fix this eventually to be much less chatty.

# Use cases
My project, Senescribe, is blogging software which can record the age of each word written in it. This age information is used to color the words of a post in a way which highlights the newest words, and points out paragraphs and sentences where the blog poster may have backtracked and edited. Users sign in using OpenID, an authentication system which uses accounts at other websites to authenticate for this one. Users need to supply their own names and email addresses after they sign in for the first time.

Each user can create a blog. They only get one blog per account. The blog stores information about the blog, like its title and number of pages viewed at once, and each post posted in the blog. When a user writes a post, the contents of the post are submitted every 3 (or so) seconds, and this data is used in two ways: it provides a backup in case the user's browser crashes can they can't submit their data, and it allows the server to find out what words exist at a given point in time.

The backup is simple: if the user hasn't clicked the submit button, if they try to create a new post, it'll show the data from the old post so they can save it. If the crash happened during editing a post, when they try to edit a post again, the autosaved data will be in the textbox.

The word count is done by splitting pieces of text by whitespace, comparing text pieces with nearby pieces from the last time the server got this information, and saving the data so it can be used later. The data is stored with the post, and when the post is viewed, this data is used to figure out how old each word is. Each word is put into an age bracket, tagged with a CSS tag, and written out as HTML.

Each post has comments. These comments are simple and don't have the ability to autosave or store the ages of words written. Any user may post on some user's entry. Anonymous comments aren't supported. However, OpenID usage is widespread, and anyone with an OpenID account can post a comment.

There are currently two styles to choose from. The stylesheets are in public/stylesheets, and the two main styles currently are default and gzwot. Default is a bland style and gzwot is something a little more unusual, with pink highlighting on newly created words to make them pop out. New stylesheets can be created by the webmaster by adding the CSS file to public/stylesheets and adding the appropriate SQL row to the styles table.

Users can be friends of other users. This feature does not have any security benefit, as all posts are publicly accessable.

## Implementation
OpenID was done using the open_id_authentication plugin. After authentication the user id is stored in the session variable. If the user logs out (or closes their browser) the user id in the session variable is cleared.

Each user can have a blog, and each blog has posts. The posts table has a few interesting columns:

- the subject of the post
- the text of the post
- is_viewable, a bool flag. Posts are created whenever a user creates a new post, even if they don't save it, because we need to save autosave information to something. To prevent newly-created-but-not-submitted-posts from being viewed, this flag starts as false but is set to true when the submit button is pressed.
- serialized_words. This is a serialized field which is an array of arrays. Each element in the main array is a "word", a collection of information like a word's text and its placement in the post. It's an array in an array because it was easy to serialize it that way. A lot of words can be read and written in a post, so this can't be a separate table with ~1000 rows, due to performance concerns.
- autosave_text. This is the text of the post when it isn't submitted. If this is blank, the post is completely saved, else it is being edited. This distinction is important because we only have word age information for the most recent version of the text of a post.

The main functions which deal with separating a post into words, and using those word ages to color the words of a post, are in lib/shared.rb. The algorithm used to figure out word ages is naive. It takes all the previously stored words, puts them in a Hash by word, and then looks up new words in the hashtable to figure out if the word existed previously. (There can be two or more of the same word in the post, and this is handled by having the entry be an array, and choosing the word in the array with the most similar index.)

Performance is an issue, since the server is doing a significant amount of work every 3 seconds. Some optimizations could be made in the algorithm for special cases, like the common case of a few words being added or removed, especially at the end. For a few users and a reasonably powerful server, it seems to work fine. 


## Features
* RSS - This is implemented in http://localhost:3000/blog/rss/{blog_number}.
* OpenID - This is the authentication system of the website. It uses the open_id_authentication plugin
* AJAX - When writing or editing a post, the information is sent to the server every 3 seconds (if a change is made), and this information lets the server know the age of words in the post. This is done using AJAX. After the age information is calculated, the data is used to apply colors to the words of a blog post, and update the area directly under the post to show what the post would look like when viewed.
