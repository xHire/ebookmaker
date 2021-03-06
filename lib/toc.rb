module Toc
  def self.generate title, author, content, content_start, show_zero, numbering
    File.open $wd.to_s + 'toc.html.stub', "w" do |f|
      # caption
      f.puts '<h1>Obsah</h1>'

      f.puts '<ul>'

      # content
      content.each_index do |i|
        number = i + content_start
        if (number == 0 and show_zero == false) or not numbering
          number = ""
        else
          number = number.to_s + ". "
        end

        f.puts "<li><a href=\"#{i + content_start}.html\">#{number}#{content[i]}</a></li>"
      end

      f.puts '</ul>'
    end
  end
end
