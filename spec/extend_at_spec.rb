require 'spec_helper'

describe 'extend_at' do
  it 'availables functions' do
    Article.respond_to?(:extra_name).should == true
    Article.respond_to?(:extra_last_name).should == true
    article = Article.new
    article.extra.respond_to?(:name).should == true
    article.extra.respond_to?(:last_name).should == true
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
  end
end
