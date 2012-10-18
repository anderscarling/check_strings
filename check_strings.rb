#! /usr/bin/env ruby
## vim: fileencoding=utf-8
require 'pathname'
require 'set'

# THIS BE VERSION 1.1
# OKTHXBYE - Anders Carling <anders.carling@footballaddicts.com>

class Array
  def each_with_object(obj)
    each { |item| yield item,obj }
    return obj
  end

  def dupes
    each_with_object(Set.new) { |v,set| set << v if count(v) > 1 }
  end
end

BASE_LANG_DIR = 'en.lproj'

def get_tuple(dir)
  file = Pathname.new(dir).join(ARGV[0] || "Localizable.strings")
  if RUBY_VERSION < '1.9.0'
    data = `cat #{file} | iconv -f UTF-16LE -t UTF-8`
  else
    data = File.open(file, 'rb:UTF-16LE:UTF-8') { |f| f.read }
  end
  data = data.lines.map { |line| line.match(/^\s?"(.+)"\s*=\s*"(.*)".*$/) }
  data.compact!

  # Check for nastys
  err_lines = data.reject { |match| match.to_s =~ /^".+"\s*=\s*".*";$/ }
  if err_lines.size > 0
    raise("Error reading #{dir}: Lines looks like data but does seem to contain errors:\n\n#{err_lines.join("\n")}")
  end

  data.map { |m| [m[1], m[2]] }
end

def print_big(sym,str)
  len = (80 - 2 - str.length) / 2.0

  puts sym*80
  puts "#{sym*len} %s #{sym*len}" % str
  puts sym*80
end

def print_report(dir, missing_in_base, missing_in_trans, identical, key_eql_val, dupes, empty)
  print_big('#', "Checking %s" % dir)

  missing_in_base.each do |key|
    puts "Missing in #{BASE_LANG_DIR} compared to #{dir}: #{key}%s"
  end

  missing_in_trans.each do |key|
    puts "Missing in #{dir} compared to #{BASE_LANG_DIR}: #{key}%s"
  end

  identical.each do |key|
    puts "Identical value in #{BASE_LANG_DIR} and #{dir}: #{key}"
  end

  key_eql_val.each do |key|
    puts "String matches translation key in #{dir}: #{key}"
  end

  dupes.each do |key|
    puts "Multiple instances of translation key in #{dir}: #{key}"
  end

  empty.each do |key|
    puts "Empty translation value in #{dir}: #{key}"
  end

  print_big(' ', "")
end

Pathname.glob("*.lproj") do |dir|
  trans       = get_tuple(dir)
  trans_keys  = trans.map(&:first)
  base        = get_tuple(BASE_LANG_DIR)
  base_keys   = base.map(&:first)
  intersect   = (trans_keys & base_keys)


  missing_in_base  = trans_keys - intersect
  missing_in_trans = base_keys  - intersect
  identical        = dir.to_s == BASE_LANG_DIR ? [] : intersect.map { |key| key if trans.find { |k,v| k == key } == base.find { |k,v| k == key } }.compact
  key_eql_val      = trans.select { |k,v| k == v }.map(&:first)
  dupes            = trans_keys.dupes
  empty            = trans.select { |k,v| v =~ /\A\s*\z/ }.map(&:first)

  print_report(dir, missing_in_base, missing_in_trans, identical, key_eql_val, dupes, empty)
end
