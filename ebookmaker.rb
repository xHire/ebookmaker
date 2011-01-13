#!/usr/bin/env ruby
# encoding: UTF-8
#####
# ebookmaker
##
# Tool for creating e-books for Kindle
###
# xHire
# xhire@mujmalysvet.cz
# http://www.mujmalysvet.cz/
#####

require 'fileutils'
require 'active_support/inflector'

if File.symlink?($0)
  Root = File.dirname(File.readlink($0))
else
  Root = File.dirname($0)
end

require File.join(Root, 'lib', 'html')
require File.join(Root, 'lib', 'ncx')
require File.join(Root, 'lib', 'opf')
require File.join(Root, 'lib', 'toc')

# set, clean and create working directory
$wd = '.build/'
FileUtils.rm_rf $wd
FileUtils.mkdir $wd

# defaults
defaults = {
  :cover => nil,
  :toc => false,
  :content_start => 1,
  :show_zero => false,
  :file => nil
}

# load book specification from yaml file
print "==> Loading book specification... "
begin
spec = YAML.load_file('book.yml')
rescue Errno::ENOENT
if spec
  puts "OK"
else
  puts "FAILED!"
  exit
end
end

spec.each do |k,v|
  spec.delete(k)
  spec[k.to_sym] = v
end

# check for required settings
print "==> Checking specification... "
first = true
[ :title, :author, :content ].each do |k|
  if spec[k].nil?
    if first
      puts "FAILED!"
      first = false
    end
    puts "Error: '#{k}' is required!"
  end
end
if first
  puts "OK"
else
  exit
end

# default unknown settings
print "==> Defaulting unspecified settings... "
defaults.each_key do |k|
  spec[k] = defaults[k] if spec[k].nil?
end
if spec[:file].nil?
  spec[:file] = spec[:author].split.reverse.join('_').parameterize + '-' + spec[:title].parameterize('_') + '.mobi'
end
puts "DONE"

# process special entities (' --' -> '&#160;&#8211;')
# title
spec[:title].sub!(' --', '&#160;&#8211;')
# content
spec[:content].collect! do |s|
  s.sub(' --', '&#160;&#8211;')
end

# generate NCX content file
print "==> Generating NCX content file... "
Ncx.generate spec[:title], spec[:author], spec[:content], spec[:content_start], spec[:show_zero]
if File.exists?($wd.to_s + 'toc.ncx')
  puts "OK"
else
  puts "FAILED!"
  exit
end

# generate HTML content file (stub)
if spec[:toc]
  print "==> Generating HTML content file... "
  Toc.generate spec[:title], spec[:author], spec[:content], spec[:content_start], spec[:show_zero]
  if File.exists?($wd.to_s + 'toc.html.stub')
    puts "OK"
  else
    puts "FAILED!"
    exit
  end
end

# create the opf
print "==> Generating OPF file... "
Opf.generate spec
if File.exists?($wd.to_s + 'book.opf')
  puts "OK"
else
  puts "FAILED!"
  exit
end

# find HTML content of the book
Dir.glob('*.html') do |f|
  next unless f =~ /^\d+\.html$/ || f =~ /^\d+-.*\.html$/
  name = f.sub /(\d+)-.*(\.html)/, '\1\2'
  FileUtils.cp f, $wd.to_s + name + ".stub"
end

# process HTML stubs
print "==> Processing HTML stubs... "
Html.process_stubs
puts "DONE"

# copy images
print "==> Copying folder images... "
if File.directory?('images')
  FileUtils.cp_r 'images', $wd
  puts "DONE"
else
  puts "NOT FOUND"
end

print "==> Copying cover... "
if File.exists?(spec[:cover])
  FileUtils.cp_r spec[:cover], $wd
  puts "DONE"
else
  puts "NOT FOUND"
end

# build mobi
puts "==> Running kindlegen... "
system "kindlegen #{$wd}book.opf -c2 -unicode -o #{spec[:file]}"
if File.exists?($wd.to_s + spec[:file])
  FileUtils.move $wd.to_s + spec[:file], '.'
  puts "==> Book is ready"
else
  puts "==> Book generation FAILED!"
  exit
end

# clean temporary files
FileUtils.rm_rf $wd
