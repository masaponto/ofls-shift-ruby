#!/usr/bin/env ruby

require 'csv'
require 'open-uri'

module OFLS

  class Shift

    def initialize(key: nil, gid: nil)
      begin
        url = 'https://docs.google.com/spreadsheets/d/' + key + '/export?format=csv&gid=' + gid
        @shift_hash = get_shift_hash(CSV.parse(open(url, "r:UTF-8")))
      rescue => e
        p e.message
      end
    end

    private
    def get_shift_hash(shift_csv)
      shift_hash = {}

      shift_csv.each do |row|
        unless row.first.nil? ||
               row.first.match(/\d*\/\d*/).nil? then

          date          = row.first.match(/\d*\/\d*/)[0]
          one_day_shift = get_one_day_shift(row[1..-1])
          shift_hash.store(date, OneDayShift.new(row.first, one_day_shift))

        end
      end

      return shift_hash
    end

    def get_one_day_shift(shift_array)
      one_day_shift = [ shift_array[0..1].join(",").sub(/,*$/, ""),
                        shift_array[2..3].join(",").sub(/,*$/, ""),
                        shift_array[4..6].join(",").sub(/,*$/, ""),
                        shift_array[7..9].join(",").sub(/,*$/, ""),
                        shift_array[10..12].join(",").sub(/,*$/, ""),
                        shift_array[13..15].join(",").sub(/,*$/, ""),
                        shift_array[16..21].join(",").sub(/,*$/, ""),
                        shift_array[22],
                        shift_array[23],
                        shift_array[24]]
    end

    def format_table(one_day_shift)
      str       = one_day_shift.date + "\n"
      fix_index = [ "1st",
                    "2nd",
                    "lun",
                    "3rd",
                    "4th",
                    "5th",
                    "nig",
                    "---\nmur",
                    "hig",
                    "etc"]

      one_day_shift.shift.each_with_index do |val, i|
        str += fix_index[i] + ": " + val + "\n" unless val.nil?
      end

      return str
    end

    public
    def date_shift(date_abs = 0)
      date = (Date.today + date_abs).strftime("%m/%d").gsub(/^0|\/0/,"")
      format_table(@shift_hash[date])
    end

    def week_shift(week_abs = 0)
      week_day    = Date.today.strftime("%w").to_i - 1
      week_start  = - week_day + week_abs * 7
      week_end    = week_start + 4
      (week_start .. week_end).map{|date| date_shift(date)}.join("\n")
    end

  end

  class OneDayShift
    attr_reader :date, :shift
    def initialize(date, shift)
      @date  = date
      @shift = shift
    end
  end

end


ofls = OFLS::Shift.new(key: ENV["OFLS_KEY"], gid: ENV["OFLS_GID"])
#puts ofls.date_shift()
puts ofls.week_shift(-1)
