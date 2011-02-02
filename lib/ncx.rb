module Ncx
  @@xmlheader = '<?xml version="1.0" encoding="utf-8"?>'

  def self.generate title, author, content, content_start, show_zero
    File.open $wd.to_s + 'toc.ncx', "w" do |f|
      # declarations
      f.puts @@xmlheader
      f.puts '<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">'
      f.puts '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="cs-CZ">'

      # head
      f.puts '<head>'
      f.puts '<meta name="dtb:uid" content="" />'
      f.puts '<meta name="dtb:depth" content="1" />'
      f.puts '<meta name="dtb:totalPageCount" content="0" />'
      f.puts '<meta name="dtb:maxPageNumber" content="0" />'
      f.puts '</head>'

      # meta info
      f.puts "<docTitle>#{title}</docTitle>"
      f.puts "<docAuthor>#{author}</docAuthor>"

      # content
      f.puts '<navMap>'

      content.each_index do |i|
        number = i + content_start
        if number == 0 and show_zero == false
          number = ""
        else
          number = number.to_s + ". "
        end

        f.puts "<navPoint id=\"ch#{i}\" playOrder=\"#{i + 1}\">"
        f.puts "<navLabel><text>#{number}#{content[i]}</text></navLabel>"
        f.puts "<content src=\"#{i + content_start}.html\" />"
        f.puts "</navPoint>"
      end

      f.puts '</navMap>'

      f.puts '</ncx>'
    end
  end
end
