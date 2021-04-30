# frozen_string_literal: true

require 'fileutils'
require 'time'

require 'archivist/media_file'
require 'streamio-ffmpeg'

module Archivist
  class Video < MediaFile
    OPTIMIZED_FORMAT = '.mp4'
    BITRATE_THRESHOLD = {
      desktop: 8388608, # 1MB/s
      web:     2097152, # 0.25MB/s
    }
    TARGET_CRF = {
      desktop: '28',
      web:     '35',
    }

    def optimize
      return if video.bitrate < BITRATE_THRESHOLD[Archivist::Config.optimize_for]

      Archivist::Logger.info("transcoding #{path}")
      video.transcode(tempfile.to_s, [
        '-map_metadata', '0', # https://video.stackexchange.com/a/26076
        '-movflags',     'use_metadata_tags',
        '-c:v',          'libx264',
        '-crf',          TARGET_CRF[Archivist::Config.optimize_for],
      ]) unless Archivist::Config.dry_run
    end

    private

    def video
      @video ||= FFMPEG::Movie.new(path.to_s)
    end

    def filename_stamp
      path.basename(path.extname).to_s.then do |filename|
        case filename
        when /^LINE_MOVIE_\d{13}$/ # LINE: UNIX time in milliseconds (at download)
          Time.strptime(filename[0..-4], 'LINE_MOVIE_%s')
        when /^VID-\d{8}-WA\d{4}$/ # WhatsApp: date + counter (at receipt)
          Time.strptime(filename, 'VID-%Y%m%d-WA%M%S')
        when /^VID_\d{8}_\d{6}_\d{3}$/ # Telegram: datetime in milliseconds (at download)
          Time.strptime(filename, 'VID_%Y%m%d_%H%M%S_%L')
        when /^signal-\d{4}-\d{2}-\d{2}-\d{6}( \(\d+\))?$/ # Signal: datetime + optional counter (at receipt)
          Time.strptime(filename[0, 24], 'signal-%F-%H%M%S')
        else
          File.mtime(path)
        end
      end
    end
  end
end
