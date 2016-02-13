class HatebRss
  attr_reader :link, :category_ja, :category_en, :title, :bookmarkcount, :description
  attr_reader :org

  CATEGORY_JA = %w[世の中 政治と経済 暮らし 学び テクノロジー おもしろ エンタメ アニメとゲーム]
  CATEGORY_EN = %w[social economics life knowledge it fun entertainment game]

  CATEGORY_EN_TO_JA = Hash[*[CATEGORY_EN, CATEGORY_JA].transpose.flatten]
  CATEGORY_JA_TO_EN = Hash[*[CATEGORY_JA, CATEGORY_EN].transpose.flatten]

  def self.from_rss(item)
    category_ja = item.at("subject")&.text || "unknown"
    seed = {
      link: item.attr("rdf:about"),
      category_ja: category_ja,
      category_en: CATEGORY_JA_TO_EN[category_ja] || "unknown",
      title: item.at("title").text,
      bookmarkcount: item.at("bookmarkcount").text.to_i,
      description: item.at("description").text,
      org: item,
    }
    self.new(seed)
  end

  def self.from_db(item)
    seed = {
      link: item.link,
      category_ja: CATEGORY_EN_TO_JA[item.category] || "unknown",
      category_en: item.category,
      title: item.title,
      bookmarkcount: item.bookmarkcount,
      description: item.description,
      org: item,
    }
    self.new(seed)
  end

  def initialize(seed)
    @link = seed[:link]
    @category_ja = seed[:category_ja]
    @category_en = seed[:category_en]
    @title = seed[:title]
    @bookmarkcount = seed[:bookmarkcount]
    @description = seed[:description]
    @org = seed[:org]
  end

  def hateb_page_link
    # TODO
    if $is_from_smartphone
      "http://b.hatena.ne.jp/entry.touch/" + @link.sub(/^https?:\/\//, "")
    else
      "http://b.hatena.ne.jp/entry/" + @link.sub(/^https?:\/\//, "")
    end
  end

  # TODO
  def yyyymmddhh
    @org.yyyymmddhh
  end
end