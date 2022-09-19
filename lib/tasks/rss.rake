require 'net/http'
require 'nokogiri'

namespace :rss do
  task :remove => :environment do
    cron_runnings = ::CronRunning.order("id DESC").limit(10).to_a
    puts "size: #{cron_runnings.size}"
    if cron_runnings.size == 10
      yyyymmddhh = cron_runnings.last.yyyymmddhh
      puts "rss:remove. yyyymmddhh < #{yyyymmddhh}"
      ::ActiveRecord::Base.transaction do
        ::HatebRss.delete_all("yyyymmddhh < #{yyyymmddhh}")
        ::CronRunning.delete_all("yyyymmddhh < #{yyyymmddhh}")
      end
    end
  end

  task :import => :environment do
    yyyymmddhh = Time.now.strftime("%Y%m%d%H")

    rsses = {}

    d = ::HatebRss.where(yyyymmddhh: yyyymmddhh).all.index_by(&:link)

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
      doc.xpath("//item").map{|i| ::Hateb.from_rss(i)}.each do |item|
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
          ::HatebRss.create!(
            yyyymmddhh: yyyymmddhh,
            link: item.link,
            category: item.category_en,
            title: item.title,
            bookmarkcount: item.bookmarkcount,
            description: item.description,
          )
        end
        ::CronRunning.create!(yyyymmddhh: yyyymmddhh)
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
            ::HatebRss.create!(
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
