require 'rubygems'
require 'nokogiri'

module Jekyll
  module BPHelpersFilters
    def git_tag(str)
      "#{`git describe --always`}".sub("\n", "")
    end

    def self.splitNavLinkItem(item, baseUrl)
      splittedItems = item.split(",")
      {
        "Name"=>    splittedItems[0],
        "Link"=>    splittedItems.length == 1 ? "#{baseUrl}/" : splittedItems[1],
        "Current"=> splittedItems.length == 1 ? 'current active' : ''
      }
    end

    def getNavLinksArray(str)
      site = @context.registers[:site]
      str.split("|").map{|s| BPHelpersFilters.splitNavLinkItem(s, site.config['baseurl'])}
    end

    def group_docs_by_type(docs)
      grouped = docs.group_by{|doc| doc.data['type']}
      grouped.keys.map{|key| {"name"=>key, "items"=>grouped[key]}}
    end
    
    def to_id_filter(str)
      BPHelpersFilters.to_id(str)
    end

    def self.to_id(str)
      str.downcase().gsub(/[^a-zA-Z]/, "-")
    end

    def replace_docs_include_filter(content)
        Jekyll::BPHelpersFilters.replace_docs_include(content)
    end

    def self.replace_docs_include(content)
      path_matches = content.scan(/(?:<\!\-\-\sdocs\-include\s)(.*?)(?:\s\-\-\>)/m)
      return content unless path_matches and path_matches.length > 0
      base_path = File.expand_path("../", File.dirname(__FILE__)) 
      path_matches.each do |capture|
        capture_fields = capture[0].split(":::") 
        include_path = capture_fields[0]
        file_path = "#{base_path}/#{include_path}"
        file_content = File.read(file_path)
        if capture_fields.length > 1
            capture_fields[1..-1].each do |field_and_value|
                key, val = field_and_value.split("=")
                file_content = file_content.gsub(key, val)
            end
        end
        file_content = self.replace_docs_include(file_content)
        puts "Including #{include_path}"
        content = content.gsub("<!-- docs-include #{capture[0]} -->", file_content)
      end
      content
    end

    def replace_section_separator(content)
      separator = "<!-- section-separator -->"
      index = 0
      return content unless content.include?(separator)

      content = "#{separator}\n\n#{content}" #as per bp-widget

      while content.include?(separator)
        index = index + 1
        content = content.sub(separator, "<div class=\"integration-separator\"><div class=\"integration-number\">#{index}</div></div>\n")
      end
      content
    end

    def replace_include_in_integration_guide(content)
        grandpa_of_all_regexes = /(<\!\-\-\seditor\-only\-start\s\-\-\>(?<=\<\!\-\-\seditor\-only\-start\s\-\-\>)(?:(.*?))(?=\<\!\-\-\seditor\-only\-end\s\-\-\>)<\!\-\-\seditor\-only\-end\s\-\-\>)/m
        father_of_all_regexes = /(<\!\-\-\sapp\-only\-start\s\-\-\>(?<=\<\!\-\-\sapp\-only\-start\s\-\-\>)(?:(.*?))(?=\<\!\-\-\sapp\-only\-end\s\-\-\>)<\!\-\-\sapp\-only\-end\s\-\-\>)/m
        aunt_of_all_regexes = /(<\!\-\-\sdocs\-only\-start\s\-\-\>|<\!\-\-\sdocs\-only\-end\s\-\-\>)/m
        content.gsub(grandpa_of_all_regexes, "").gsub(father_of_all_regexes, "").gsub(aunt_of_all_regexes, "")
    end

    def replace_media_links(content)
      site = @context.registers[:site]
      #site.config["production"] ? content : content.gsub(/src="\/media/, "src=\"#{site.config["baseurl"]}/media")
      content.gsub(/src="\/media/, "src=\"#{site.config["baseurl"]}/media")
    end

    def self.get_sorted_collections(a, opt_site=nil)
      cols = []
      site = opt_site.nil? ? @context.registers[:site] : opt_site
      site.config["collections"].keys.each{ |key| cols << CollectionEntry.create_from_collection(site.collections[key], site, key)}
      cols 
    end

    def get_sorted_collections_filter(a)
      Jekyll::BPHelpersFilters.get_sorted_collections(a, @context.registers[:site])
    end
  end

  class DocEntry
    attr_reader   :slug, :content, :headers, :data

    def initialize(doc)
      @slug, @content, @data = SlugEntry.new(doc.data["title"]), doc.content, doc.data
      if doc.content.include?("###") #isMarkdown
        @headers = doc.content.split("\n").select{|i| i[/^\#\#\#\s/]}.map{ |n| n.sub("### ", "")}.map{ |m| SlugEntry.new(m)}
      else
        @headers = Nokogiri::HTML(doc.content).xpath("//h3").map(&:content).map{ |m| SlugEntry.new(m)};
      end
    end

    def to_liquid
      {
        "slug"=> @slug,
        "content"=> @content,
        "headers"=> @headers,
        "data"=> @data
      }
    end
  end

  class SlugEntry
    attr_reader   :title, :href

    def initialize(name)
      @title = name
      @href = Jekyll::BPHelpersFilters::to_id(@title) 
    end

    def to_liquid
      {
        "title"=> @title,
        "href"=> @href,
      }
    end
  end

  class CollectionEntry
    attr_reader   :docs, :size, :slug, :name

    def filter_drafts(docs)
      @site.config["production"] ? docs.select{ |d| d.data["draft"] != true} : docs
    end

    def initialize(docs, title, site, name)
      @site, @slug, @name = site, SlugEntry.new(title), name
      docs_unsorted = filter_drafts(docs.map{|doc| DocEntry.new(doc)})
      @docs = docs_unsorted.sort{|x,y | y.slug.title<=>x.slug.title}.reverse
      @size = @docs.length
    end

    def self.create_from_collection(col, site, name)
      CollectionEntry.new(col.docs, col.metadata["title"], site, name)
    end

    def to_liquid
      {
        "docs"=> @docs,
        "size"=> @size,
        "slug"=> @slug,
        "name"=> @name
      }
    end
  end
end

Liquid::Template.register_filter(Jekyll::BPHelpersFilters)
