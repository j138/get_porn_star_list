#!/usr/local/bin/ruby
# coding: utf-8
require 'net/http'
require 'uri'
require 'nokogiri'

wikipedia_pages = %W(
  AV女優一覧_あ行
  AV女優一覧_か行
  AV女優一覧_さ行
  AV女優一覧_た行
  AV女優一覧_な行
  AV女優一覧_は行
  AV女優一覧_ま行
  AV女優一覧_や行
  AV女優一覧_ら・わ行
)

def http_request(unescape_uri)
  uri = URI.escape(unescape_uri)
  uri_parsed = URI.parse(uri)
  http = Net::HTTP.new(uri_parsed.host, uri_parsed.port)
  # http.set_debug_output $stderr

  http.get(uri).body
end

porn_stars = []
wikipedia_pages.each do |uri|
  doc = Nokogiri::HTML.parse(http_request('http://ja.wikipedia.org/wiki/' + uri))
  is_porn_star = false

  # 「6 関連項目」から下、「アダルトビデオ」の項目から上のanchorのテキストを引き抜く
  doc.css('#mw-content-text ul li a').each do |node|
    text = node.children.text

    if text == '6 関連項目'
      is_porn_star = true
      next
    end
    break if text == 'アダルトビデオ'
    porn_stars.push(text) if is_porn_star
  end
end

filename = format('porn_star_list-%s.txt', Time.now.strftime('%Y%m%d'))
File.write(filename, porn_stars.join("\n"))
puts 'output: ' + filename
