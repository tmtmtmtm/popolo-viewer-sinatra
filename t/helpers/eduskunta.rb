
require 'popolo_helper'
require 'minitest/autorun'

include Popolo::Helper

describe "Eduskunta" do

  subject { Popolo::Data.new('eduskunta') }

  describe "party" do

    let(:party) { subject.party_from_id('kok') }

    it "should get the correct party" do
      party['name'].must_equal 'National Coalition Party'
    end

  end

  describe "person" do

    let(:person) { subject.person_from_id('1031') }
    let(:mems) { subject.person_memberships(person) }

    it "should get the correct person" do
      person['name'].must_equal 'Stubb Alexander'
    end

    it "should have a membership" do
      mems.count.must_equal 1
    end

    it "should be in the legislature" do
      mems.first['organization_id'].must_equal 'legislature'
    end

    it "should have an expanded Organization" do
      mems.first['organization']['name'].must_equal 'Eduskunta'
    end

    it "should have an expanded Party" do
      mems.first['on_behalf_of']['name'].must_equal 'National Coalition Party'
    end

  end

  describe "term" do

    let(:term) { subject.term_from_id('34') }
    let(:mems) { subject.term_memberships(term) }

    it "should get the correct term" do
      term['name'].must_equal 'Eduskunta 34 (2003)'
    end

    it "should have 214 memberships" do
      mems.count.must_equal 214
    end

    it "should have someone who joined mid-term" do
      mems.map { |m| m['person']['name'] }.must_include 'Donner Jörn'
    end

    it "should have someone who left mid-term" do
      mems.map { |m| m['person']['name'] }.must_include 'Laisaari Sinikka'
    end

  end

  describe "old term" do

    let(:term) { subject.term_from_id('27') }
    let(:mems) { subject.term_memberships(term) }

    it "should get the correct term" do
      term['name'].must_equal 'Eduskunta 27 (1975 II)'
    end

    it "should have 8 memberships" do
      mems.count.must_equal 8
    end

    it "should have someone who joined before" do
      mems.map { |m| m['person']['name'] }.must_include 'Tuomioja Erkki'
    end

    it "should have someone who joined at that term" do
      mems.map { |m| m['person']['name'] }.must_include 'Stenius-Kaukonen Marjatta'
    end

    it "should have someone still serving" do
      mems.map { |m| m['person']['name'] }.must_include 'Kanerva Ilkka'
    end

  end

end