function ffmpeg-extract-frames --wraps=ffmpeg\ \'\%04d.png\'\ -i --description alias\ ffmpeg-extract-frames=ffmpeg\ \'\%04d.png\'\ -i
  ffmpeg '%04d.png' -i $argv
        
end
