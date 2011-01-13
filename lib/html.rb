module Html
  def self.process_stubs
    Dir.glob($wd.to_s + '*.html.stub') do |fn|
      name = fn.sub '.stub', ''
      File.open name, "w" do |f|
        # declarations
        f.puts '<html>'

        # head
        f.puts '<head>'
        f.puts '<meta http-equiv="content-type" content="text/html; charset=utf-8" />'
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
