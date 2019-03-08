# frozen_string_literal: true
require 'spec_helper'

RSpec.describe HamdownParser::IndentTracker do
  it 'raises error if indent is wrong' do
    expect { parse(<<HAML) }.to raise_error(HamdownParser::IndentTracker::IndentMismatch) { |e|
%div
    %div
        %div
  %div
HAML
      aggregate_failures do
        expect(e.current_level).to eq(2)
        expect(e.indent_levels).to eq([0])
        expect(e.lineno).to eq(4)
      end
    }
  end

  it 'raises error if the current indent is deeper than the previous one' do
    expect { parse(<<HAML) }.to raise_error(HamdownParser::IndentTracker::InconsistentIndent) { |e|
%div
  %div
      %div
HAML
      aggregate_failures do
        expect(e.previous_size).to eq(2)
        expect(e.current_size).to eq(4)
        expect(e.lineno).to eq(3)
      end
    }
  end

  it 'raises error if the current indent is shallower than the previous one' do
    expect { parse(<<HAML) }.to raise_error(HamdownParser::IndentTracker::InconsistentIndent) { |e|
%div
    %div
      %div
HAML
      aggregate_failures do
        expect(e.previous_size).to eq(4)
        expect(e.current_size).to eq(2)
        expect(e.lineno).to eq(3)
      end
    }
  end

  it 'raises error if indented with hard tabs' do
    expect { parse(<<HAML) }.to raise_error(HamdownParser::IndentTracker::HardTabNotAllowed)
%p
	%a
HAML
  end

  it 'raise error when the first line has indentation' do
    expect { parse(<<HAML) }.to raise_error(HamdownParser::Error)
  foo
HAML
  end
end
