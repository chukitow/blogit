require "rails_helper"

describe Blogit::ApplicationHelper do

  describe :blog_tag do
    it "should create a tag element and give it a 'blog_post... prefixed class" do
      expect(helper.blog_tag(:div, "hello", id: "blog_div", class: "other_class")).to eq(%{<div class="other_class blog_post_div" id="blog_div">hello</div>})
      expect(helper.blog_tag(:li, "hello", id: "blog_li")).to eq(%{<li class="blog_post_li" id="blog_li">hello</li>})
    end

    it "should create a comment tag element when the comment type options is set" do
      expect(helper.blog_tag(:div, "hello", id: "blog_div", type: "comment", class: "other_class")).to eq(%{<div class="other_class blog_comment_div" id="blog_div">hello</div>})
      expect(helper.blog_tag(:li, "hello", id: "blog_li", type: "status")).to eq(%{<li class="blog_status_li" id="blog_li">hello</li>})
    end
  end

  describe "format_content" do
    it "should convert markdown text to html if conf is :markdown" do
      Blogit.configure { |c| c.default_parser = :markdown }
      expect(helper.format_content("## Hello\n\nWorld")).to match(/<h2>Hello<\/h2>\n\n<p>World<\/p>/)
    end

    it "should convert textile text to html if conf is :textile" do
      Blogit.configure { |c| c.default_parser = :textile }
      expect(helper.format_content("h1. Hello\n\nWorld")).to eq("<h1>Hello</h1>\n<p>World</p>")
    end

    it "should convert html text to html if conf is :html" do
      Blogit.configure { |c| c.default_parser = :html }
      expect(helper.format_content("<h1>Hello</h1>\n\n<p>World</p>")).to eq("<h1>Hello</h1>\n\n<p>World</p>")
    end
  end

  describe :actions do
    it "should create a div with class 'actions'" do
      expect(helper.actions do
        "hello"
      end).to eq(%{<div class="actions">hello</div>})
    end
  end

  describe "main app's named routes" do
    # rspec generates a helper by mixin in the tested helper and the application
    # helper. But this is not what is being done by rails inside an engine.
    # This mockery is more like the real thing
    class MainAppApplicationHelperBench
      def dummy_thing_path
        "/dummy_thing"
      end
      def dummy_thing_url
        "http://host/dummy_thing"
      end
      def secret
      end
    end
    class BlogitApplicationHelperBench
      include Blogit::ApplicationHelper

      def main_app
        MainAppApplicationHelperBench.new
      end
    end

    let(:raw_helper) { BlogitApplicationHelperBench.new }

    it "should not know named routes of the main app if not configured" do
      Blogit.configure {|c| c.inline_main_app_named_routes = false }

      expect { raw_helper.dummy_thing_path }.to raise_error(NoMethodError)
      expect { raw_helper.dummy_thing_url }.to raise_error(NoMethodError)
    end

    it "should know named routes of the main app" do
      Blogit.configure {|c| c.inline_main_app_named_routes = true }

      expect(raw_helper.dummy_thing_path).to eq("/dummy_thing")
      expect(raw_helper.dummy_thing_url).to eq("http://host/dummy_thing")
    end

    it "should not know anything but named routes of the main app" do
      Blogit.configure {|c| c.inline_main_app_named_routes = true }

      expect { raw_helper.secret }.to raise_error(NoMethodError)
    end

    it "should not know other routes" do
      Blogit.configure {|c| c.inline_main_app_named_routes = true }

      expect { raw_helper.junk_path }.to raise_error(NoMethodError)
      expect { raw_helper.junk_url }.to raise_error(NoMethodError)
    end

  end
end
