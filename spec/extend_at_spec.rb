require 'spec_helper'

describe 'extend_at' do
  it 'availables functions' do
    Article.respond_to?(:extra_name).should == true
    Article.respond_to?(:extra_last_name).should == true
    article = Article.new
    article.extra.respond_to?(:name).should == true
    article.extra.respond_to?(:last_name).should == true
  end

  it 'without mass assignment should work' do
    article = Article.new
    article.save
    article.extra.last_name = "Gonzales"
    article.save
    article.reload
    article.extra.last_name.should == "Gonzales"

    user = User.new
    user.save
    user.private_info.real_name = "Pedro"
    user.save
    user.reload
    user.private_info.real_name.should == "Pedro"
  end

  it 'when is loaded, should load the extra information' do
    article = Article.new :extra_name => 'Pedro', :extra_last_name => 'Gonzales'
    article.extra.name.should == 'Pedro'
    article.extra.last_name.should == 'Gonzales'
    article.save

    article = Article.last
    article.extra.name.should == "Pedro"
    article.extra.last_name.should == "Gonzales"
  end

  it "mass assignment" do
    article = Article.new :extra_name => 'Pedro', :extra_last_name => 'Gonzales'
    article.extra.name.should == 'Pedro'
    article.extra.last_name.should == 'Gonzales'
    article.extra_name.should == 'Pedro'
    article.extra_last_name.should == 'Gonzales'
    article[:extra_name].should == 'Pedro'
    article[:extra_last_name].should == 'Gonzales'
    article.save
    article.reload
    article.extra.name.should == 'Pedro'
    article.extra.last_name.should == 'Gonzales'
    article.extra_name.should == 'Pedro'
    article.extra_last_name.should == 'Gonzales'
    article[:extra_name].should == 'Pedro'
    article[:extra_last_name].should == 'Gonzales'
  end

  describe "columns options" do
    
    it "accept lambda" do
      user = User.new :name => 'account'
      user.private_info.class.should == ExtendModelAt::Extention
    end

    it "type should accept symbol" do
      article = Article.new :extra_int1 => 10
      article.extra.int1.class.should == Fixnum
    end

    it "should accept default value" do
      article = Article.new
      article.extra_int1.should == 1
    end

    it "should accept symbol" do
      article = Article.new
      article.extra.all_names.include? 'int2'
      article.extra.int2 = 10
      article.extra.int2.class.should == Fixnum
    end

    it "type should accept lambda" do
      article = Article.new
      article.extra.int2 = 10
      article.extra.int2.class.should == Fixnum
    end

    it "should accept validate" do
      article = Article.new :extra_int1 => -1
      article.save
      article.errors.keys.include?(:extra_int1).should == true
    end
  end

  context "general options" do
    it "should support static columns" do
      user = User.new :name => "Account"
      lambda {user.private_info.etc = "etc"}.should raise_error(ExtendModelAt::InvalidColumn)
    end

    it "if isn't static should support dynamic columns" do
      article = Article.new
      lambda {article.extra.etc = "etc"}.should_not raise_error(ExtendModelAt::InvalidColumn)
      article.save :validate => false
      article.reload
      article.extra.etc.should == "etc"
    end
  end

  context "associations support" do
    context "belongs_to" do
      it "simple usage" do
        tool = Tool.new
        tool.extra.name = "Hammer"
        tool.save
        tool.extra.respond_to?(:create_toolbox).should == true
        tool.extra.create_toolbox(:name => "Toolbox").should == true
        tool.extra.toolbox.class.should == Toolbox
        tool.extra.toolbox.name.should == "Toolbox"
      end
    end

    context "has_many" do
      it "simple usage" do
        pending "Working on it"
        tool = Tool.new
        tool.extra.name = "Hammer"
        tool.save
        tool.extra.respond_to?(:create_toolbox).should == true
        tool.extra.create_toolbox.should == true
        tool.extra.create_toolbox.should == true
        tool.extra.toolbox.class.should == Toolbox
        box = Toolbox.new
        box.save
        box.extra.create_tool
        box.extra.create_tool
        box.extra.create_tool
        box.extra.tools.class.should == Array
        box.extra.tools.size.should == 3
        box.extra.tools.first.extra.toolbox.should == box
      end
    end
  end
end
