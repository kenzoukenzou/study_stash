# == Schema Information
#
# Table name: portfolios
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  url         :string
#  ogp_url     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Portfolio < ApplicationRecord
  require 'open-uri'
  has_many :portfolio_tags, dependent: :destroy
  has_many :tags, through: :portfolio_tags
  validates :url, presence: :true
  validates :url, format: { with: /\A#{URI.regexp(%w[http https])}\z/ }
  before_save :get_meta_datas

  def get_meta_datas
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    # TODO: nil判定をリファクタ
    self.title = doc.title
    self.description = get_og_data(doc, '//meta[name="description"]/@content') if description.blank?
    self.ogp_url = get_og_data(doc, '//meta[property="og:image"]/@content') if ogp_url.blank?
  end

  def get_og_data(doc, xpath)
    doc.css(xpath).each { |node| node.inner_text }
  end
end