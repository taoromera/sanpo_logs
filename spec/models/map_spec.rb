# -*- coding: utf-8 -*-
require 'spec_helper'

describe Map do

  describe '#text_box_from_coordinates' do
    before(:all) do
      @point = Map.create_point(140, 70)
    end

    it 'should work without second parameter' do
      box = Map.text_box_from_coordinates(@point)
      box.should == "139.9 69.9, 140.1 70.1"
    end

    it 'should work with positive parameters' do
      box = Map.text_box_from_coordinates(@point, 1)
      box.should == "139.5 69.5, 140.5 70.5"
    end

  end

  describe '#factory' do
    it 'should not be nil' do
      Map.factory.should_not be_nil
    end
  end

  describe '#find_by_coordinates' do
    it 'should return a db record from a valid coordinates' do
      pending
    end
  end


end
