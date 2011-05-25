module Html
  def self.process_stubs css
    Dir.glob($wd.to_s + '*.html.stub') do |fn|
      name = fn.sub '.stub', ''
      File.open name, "w" do |f|
        # declarations
        f.puts '<html>'

        # head
        f.puts '<head>'
        f.puts '<meta http-equiv="content-type" content="text/html; charset=utf-8" />'
        if css
          f.puts '<style type="text/css">'
          File.readlines('style.css').each do |l|
            f.puts l.chop
          end
          f.puts '</style>'
        end
        f.puts '</head>'

        # body
        f.puts '<body>'
        f.puts IO.read fn
        f.puts '</body>'

        f.puts '</html>'
      end
    end
  end
end
