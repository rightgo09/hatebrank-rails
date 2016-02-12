require 'net/http'
require 'nokogiri'

namespace :rss do
  task :import do
    yyyymmddhh = Time.now.strftime("%Y%m%d%H")

    rsses = {}

    d = ::Db::HatebRss.where(yyyymmddhh: yyyymmddhh).all.index_by(&:link)

    # http://b.hatena.ne.jp/hotentry.rss
    # http://b.hatena.ne.jp/video.rss
    %w[
      http://feeds.feedburner.com/hatena/b/hotentry

      http://b.hatena.ne.jp/hotentry/social.rss
      http://b.hatena.ne.jp/hotentry/economics.rss
      http://b.hatena.ne.jp/hotentry/life.rss
      http://b.hatena.ne.jp/hotentry/knowledge.rss
      http://b.hatena.ne.jp/hotentry/it.rss
      http://b.hatena.ne.jp/hotentry/entertainment.rss
      http://b.hatena.ne.jp/hotentry/game.rss
      http://b.hatena.ne.jp/hotentry/fun.rss

      http://feeds.feedburner.com/hatena/b/video
    ].each do |url|
      res = Net::HTTP.get_response(URI(url))
      doc = ::Nokogiri::HTML(res.body)
      doc.xpath("//item").map{|i| ::HatebRss.from_rss(i)}.each do |item|
        if rsses.has_key?(item.link)
          if rsses[item.link].bookmarkcount < item.bookmarkcount
            rsses[item.link] = item
          end
        else
          rsses[item.link] = item
        end
      end
      puts "sleep 1..."
      sleep(1)
    end

    if d.empty?
      puts "d is empty"
      ::ActiveRecord::Base.transaction do
        rsses.each do |link, item|
          puts "link: #{link}"
          ::Db::HatebRss.create!(
            yyyymmddhh: yyyymmddhh,
            link: item.link,
            category: item.category_en,
            title: item.title,
            bookmarkcount: item.bookmarkcount,
            description: item.description,
          )
        end
        ::Db::CronRunning.create!(yyyymmddyy: yyyymmddhh)
      end
    else
      puts "d is not empty"
      ::ActiveRecord::Base.transaction do
        rsses.each do |link, item|
          puts "link: #{link}"
          if d.has_key?(link)
            puts "update"
            d[link].update(
              category: item.category_en,
              title: item.title,
              bookmarkcount: item.bookmarkcount,
              description: item.description,
            )
          else
            puts "insert"
            ::Db::HatebRss.create!(
              yyyymmddhh: yyyymmddhh,
              link: item.link,
              category: item.category_en,
              title: item.title,
              bookmarkcount: item.bookmarkcount,
              description: item.description,
            )
          end
        end
      end
    end
  end
end