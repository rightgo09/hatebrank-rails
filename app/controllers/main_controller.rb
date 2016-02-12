class MainController < ApplicationController
  def index
    ymdhs = ::Db::CronRunning.order("id DESC").limit(2).map(&:yyyymmddhh)
    now_ymdh, prev_ymdh = ymdhs
    rsses = {}
    if now_ymdh
      rsses[now_ymdh] = ::Db::HatebRss.where(yyyymmddhh: now_ymdh).limit(50).map{|item| ::HatebRss.from_db(item)}
    end
    if prev_ymdh
      rsses[prev_ymdh] = ::Db::HatebRss.where(yyyymmddhh: prev_ymdh).map{|item| ::HatebRss.from_db(item)}
    end
    @rsses = []
    if rsses.has_key?(now_ymdh) && rsses.has_key?(prev_ymdh)
      rsses[now_ymdh].each do |now_rss|
        if prev_rss = rsses[prev_ymdh].find{|prev_rss| prev_rss.link == now_rss.link}
          @rsses << {
            diff_bookmarkcount: now_rss.bookmarkcount - prev_rss.bookmarkcount,
            rss: now_rss,
          }
        else
          @rsses << {
            diff_bookmarkcount: now_rss.bookmarkcount,
            rss: now_rss,
          }
        end
      end
    elsif rsses.has_key?(now_ymdh)
      rsses[now_ymdh].each do |now_rss|
        @rsses << {
          diff_bookmarkcount: now_rss.bookmarkcount,
          rss: now_rss,
        }
      end
    end
    @rsses.sort_by!{|rss| rss[:diff_bookmarkcount]}.reverse!
  end
end
