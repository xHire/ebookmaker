module Opf
  @@xmlheader = '<?xml version="1.0" encoding="utf-8"?>'
  @@mime_types = {
    "bmp"  => "image/bmp",
    "gif"  => "image/gif",
    "htm"  => "application/xhtml+xml",
    "html" => "application/xhtml+xml",
    "jpe"  => "image/jpeg",
    "jpeg" => "image/jpeg",
    "jpg"  => "image/jpeg",
    "png"  => "image/png",
    "tif"  => "image/tiff",
    "tiff" => "image/tiff"
  }

  def self.generate spec
    File.open $wd.to_s + 'book.opf', "w" do |f|
      # declarations
      f.puts @@xmlheader
      f.puts '<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="BookId">'

      # metadata
      f.puts '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">'
      f.puts '<dc:language>cs</dc:language>'
      f.puts "<dc:title>#{spec[:title]}</dc:title>"
      f.puts "<dc:creator>#{spec[:author]}</dc:creator>"

      f.puts '<meta name="cover" content="cover" />' if spec[:cover]
      f.puts '</metadata>'

      # manifest of all used files
      f.puts '<manifest>'
      spec[:content].each_index do |i|
        n = i + spec[:content_start]
        f.puts "<item id=\"item#{n}\" media-type=\"application/xhtml+xml\" href=\"#{n}.html\"></item>"
      end

      f.puts '<item id="toc" media-type="application/xhtml+xml" href="toc.html"></item>' if spec[:toc]
      f.puts '<item id="toc_ncx" media-type="application/x-dtbncx+xml" href="toc.ncx" />'
      f.puts "<item id=\"cover\" media-type=\"#{@@mime_types[spec[:cover].split('.').last]}\" href=\"#{spec[:cover]}\" />" if spec[:cover]
      f.puts '</manifest>'

      # spine + internal toc (defines the linear reading order of the book)
      f.puts '<spine toc="toc_ncx">'
      f.puts '<itemref idref="toc" />' if spec[:toc] and spec[:toc_position] == :start
      spec[:content].each_index do |i|
        f.puts "<itemref idref=\"item#{i + spec[:content_start]}\"/>"
      end
      f.puts '<itemref idref="toc" />' if spec[:toc] and spec[:toc_position] == :end
      f.puts '</spine>'

      # I have no clue what this does...
      f.puts '<guide>'
      f.puts '<reference type="toc" title="Obsah" href="toc.html"></reference>' if spec[:toc] and spec[:toc_position] == :start
      # this is probably the place where reading starts
      f.puts "<reference type=\"text\" title=\"#{spec[:content][0]}\" href=\"#{spec[:content_start]}.html\"></reference>"
      f.puts '<reference type="toc" title="Obsah" href="toc.html"></reference>' if spec[:toc] and spec[:toc_position] == :end
      f.puts '</guide>'

      f.puts '</package>'
    end
  end
end
