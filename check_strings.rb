#! /usr/bin/env ruby
## vim: fileencoding=utf-8
require 'pathname'

BASE_LANG_DIR = 'en.lproj'

def get_hash(dir)
  file = Pathname.new(dir).join(ARGV[0] || "Localizable.strings")
  data = File.open(file, 'rb:UTF-16LE:UTF-8') { |f| f.read }
  data = data.lines.map { |line| line.match(/"(.+)"\s*=\s*"(.*)"/) }
  data = data.compact.map { |m| [m[1], m[2]] }
  Hash[data]
end

def print_big(sym,str)
  len = (80 - 2 - str.length) / 2.0

  puts sym*80
  puts "#{sym*len} %s #{sym*len}" % str
  puts sym*80
end

def print_report(dir, trans, base, identical, key_eql_val)
  print_big('#', "Checking %s" % dir)

  base.each do |key|
    puts "Missing in #{dir} compared to #{BASE_LANG_DIR}: #{key}%s"
  end

  trans.each do |key|
    puts "Missing in #{BASE_LANG_DIR} compared to #{dir}: #{key}%s"
  end

  identical.each do |key|
    puts "Identical value in #{BASE_LANG_DIR} and #{dir}: #{key}"
  end

  key_eql_val.each do |key|
    puts "String matches translation key in #{dir}: #{key}"
  end

  print_big(' ', "")
end

Pathname.glob("*.lproj") do |dir|
  next if dir.to_s == BASE_LANG_DIR

  trans     = get_hash(dir)
  base      = get_hash(BASE_LANG_DIR)
  intersect = (trans.keys & base.keys)

  identical = intersect.map { |key| key if trans[key] == base[key] }.compact
  print_report(dir, trans.keys - intersect, base.keys - intersect, identical, trans.select { |k,v| k == v }.keys)
end
